pragma solidity ^0.8.0;

contract Votacao {
    address public owner;  // endereço do dono do contrato
    uint public votacaoID;  // ID da votação atual
    uint public deadline;  // prazo final da votação em timestamp Unix
    uint public quorum;  // quórum necessário para aprovação da votação
    uint public simCount;  // contagem de votos "sim"
    uint public naoCount;  // contagem de votos "não"
    mapping(address => bool) public votou;  // mapeia se um endereço já votou
    mapping(address => bool) public votos;  // mapeia o voto de um endereço

    // evento emitido quando uma votação é iniciada
    event VotacaoIniciada(uint indexed votacaoID, uint indexed deadline, uint quorum);

    // evento emitido quando uma votação é encerrada
    event VotacaoEncerrada(uint indexed votacaoID, uint simCount, uint naoCount);

    // evento emitido quando um endereço vota em uma votação
    event VotoRegistrado(address indexed votante, bool indexed voto);

    constructor(uint _deadline, uint _quorum) {
        owner = msg.sender;
        votacaoID = 0;
        deadline = _deadline;
        quorum = _quorum;
        simCount = 0;
        naoCount = 0;
        emit VotacaoIniciada(votacaoID, deadline, quorum);
    }

    // função para votar na votação atual
    function votar(bool _voto) public {
        require(block.timestamp < deadline, "Votação encerrada.");
        require(!votou[msg.sender], "Endereço já votou.");
        votou[msg.sender] = true;
        votos[msg.sender] = _voto;
        if (_voto) {
            simCount++;
        } else {
            naoCount++;
        }
        emit VotoRegistrado(msg.sender, _voto);
    }

    // função para encerrar a votação atual
    function encerrarVotacao() public {
        require(msg.sender == owner, "Somente o dono pode encerrar a votação.");
        require(block.timestamp >= deadline, "Votação ainda em andamento.");
        require(simCount >= quorum, "Quórum mínimo não alcançado.");
        emit VotacaoEncerrada(votacaoID, simCount, naoCount);
        votacaoID++;
        simCount = 0;
        naoCount = 0;
        deadline = block.timestamp + 86400;  // prazo de um dia para a próxima votação
        emit VotacaoIniciada(votacaoID, deadline, quorum);
    }
}
