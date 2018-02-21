pragma solidity ^0.4.19;

// Proof of Existence contract
contract ProofOfExistence {

  //Mapeo de Hash -> verified
  mapping (bytes32 => bool) private proofs;

  //Almacena una nueva PoE (hash)
  function storeProof(bytes32 proof) {
    proofs[proof] = true;
  }

  //Calucula y almacena una nueva PoE (hash de un documento)
  function notarize(string document) {
    var proof = proofFor(document);
    storeProof(proof);
  }

  //Devuelve el hash del documento
  function proofFor(string document) constant returns (bytes32) {
    return sha256(document);
  }

  //Comprueva si el documento ya ha sido validado con PoE
  function checkDocument(string document) constant returns (bool) {
    var proof = proofFor(document);
    return hasProof(proof);
  }

  //Retorna true si el documento ya tiene PoE
  function hasProof(bytes32 proof) constant returns(bool) {
    return proofs[proof];
  }
}