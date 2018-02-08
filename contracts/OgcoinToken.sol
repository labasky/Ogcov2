pragma solidity ^0.4.18;

import '/Users/og/Ogcoinv2/node_modules/zeppelin-solidity/contracts/token/MintableToken.sol';

contract OgcoinToken is MintableToken {
  string public name = "Ogcoin - The first distributed E-Health Token for Africa";
  string public symbol = "Ogc";
  uint8 public decimals = 18;
}
