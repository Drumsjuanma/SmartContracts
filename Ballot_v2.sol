pragma solidity ^0.4.19;

/// Smart Contract de votacion
///@author drumsjuanma
contract Ballot {


    //Estructura de datos que representa un unico votante
    struct Voter {
        uint weight; // Peso del voto
        bool voted;  // If true, la persona ya ha votado
        address delegate; // Persona a la que se le delega el voto
        uint vote;   // Index de la propuesta votada
    }

    // Estructura de datos que representa una propuesta de la votacion
    struct Proposal {
        bytes32 name;   // Nombre de la propuesta (hasta 32 bytes)
        uint voteCount; // Numero de votos acumulados
    }

    // Maping entre direcciones de usuarios al struct de Voter
    mapping(address => Voter) public voters;

    // Mapping entre direcciones de usuarios i booleans de chairperson
    // Los Chairperson asignan los usuarios que pueden votar. Por defecto solo el 
    // creador del Smart Contract
    mapping(address => bool) public chairpersons;

    // Array dinamica de los nombres de las propuestas
    Proposal[] public proposals;
    
    // False si la votacion ha finalizado
    bool canVote;

    /// Crea una nueva votacion con las propuestas pasadas
    function Ballot (bytes32[] proposalNames) public {
        chairpersons[msg.sender] = true;
        canVote = true;
        // Por cada propuesta pasada al constructor se anade una nueva al
        // array de propuestas
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i],voteCount: 0}));
        }
    }
    
    //Funcion para terminar la votacion
    function closeBallot() public onlyChairperson {
        canVote = false;
    }

    // Funcion para asignar responsables de la votacion
    function setChairperson(address addr) public onlyChairperson{
        chairpersons[addr] = true;
    }
    
    //Funcion para obtener el nombre de una propuesta
    function getProposalName(uint index) public constant returns (string) {
        return bytes32ToString(proposals[index].name);
    }
    

    // Da derecho de voto a una direccion 
    // Solo puede ser invocado por el chairperson 
    function giveRightToVote(address voter) public onlyChairperson {
        if (chairpersons[msg.sender]!=true || voters[voter].voted) {
            revert();
        }
        voters[voter].weight = 1;
    }

    /// Delega el voto a otra direccion
    function delegate(address to) public onlyOnOpenBallot{
        Voter storage sender = voters[msg.sender];
        if (sender.voted){
            revert();
        }

        // Delegacion recursiva
        while (voters[to].delegate != address(0) && voters[to].delegate != msg.sender) {
            to = voters[to].delegate;
        }

        // Si hay un bucle en la delegacion, error
        if (to == msg.sender) {
            revert();
        }

        // 'Sender' es una referencia a voters[msg.sender]
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegated = voters[to];
        if (delegated.voted) {
            //Si el delegado ya ha votado, se suman los votos a la propuesta
            proposals[delegated.vote].voteCount += sender.weight;
        } else {
            // Si el delegado no ha votado, se le anade un voto al peso
            delegated.weight += sender.weight;
        }
    }


    /// Funcion para votar la propuesta dada su indice en el array
    function vote(uint proposal) public onlyOnOpenBallot{
        Voter storage sender = voters[msg.sender];
        if (sender.voted){
            revert();
        }
        sender.voted = true;
        sender.vote = proposal;

        // Si la propuesta esta fuera de rango se deshacen los cambios automaticamente
        proposals[proposal].voteCount += sender.weight;
    }

    /// Devuelve el indice de la propuesta ganadora
    function winningProposal() public constant returns (uint proposal){
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                proposal = p;
            }
        }
    }

    // Devuelve el nombre de la propuesta ganadora
    function winnerName() public constant returns (bytes32 winner){
        winner = proposals[winningProposal()].name;
    }
    
    
    
    function bytes32ToString (bytes32 data)private pure returns (string) {
        bytes memory bytesString = new bytes(32);
        for (uint j=0; j<32; j++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
    }
    
    modifier onlyChairperson {
        require(chairpersons[msg.sender]);
        _;
    }
    
    modifier onlyOnOpenBallot {
        require(canVote);
        _;
    }
    
}