pragma solidity ^0.4.18;

import './OgcoinToken.sol';
import '/Users/og/Ogcoinv2/node_modules/zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
import '/Users/og/Ogcoinv2/node_modules/zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol';

contract OgcoincrowdSale is CappedCrowdsale, RefundableCrowdsale {

  // ICO Stage
  // ============
  enum CrowdsaleStage { PreICO, ICO }
  CrowdsaleStage public stage = CrowdsaleStage.PreICO; // By default it's Pre Sale
  // =============

  // Token Distribution
  // =============================
  uint256 public maxTokens = 700000000000000000000000000; // There will be total 700000000 Ogcoin Tokens
  uint256 public tokensForEcosystem = 200000000000000000000000000;// 200million out of 700million for Ogsoft Systems and services
  uint256 public tokensForTeam = 200000000000000000000000000; //  200million out of 500million for teams worldwide
  uint256 public tokensForBounty = 150000000000000000000000000; // 150 million for bounty production on exchanges
  uint256 public totalTokensForSale = 150000000000000000000000000; // 150 million Ogcoin will be sold in Crowdsale
  uint256 public totalTokensForSaleDuringPreICO = 70000000000000000000000000; // 70million out of 150million OGC will be sold during PreICO
  // ==============================

  // Amount raised in PreICO
  // ==================
  uint256 public totalWeiRaisedDuringPreICO;
  // ===================


  // Events
  event EthTransferred(string text);
  event EthRefunded(string text);


  // Constructor
  // ============
  function OgcoincrowdSale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _goal, uint256 _cap) CappedCrowdsale(_cap) FinalizableCrowdsale() RefundableCrowdsale(_goal) Crowdsale(_startTime, _endTime, _rate, _wallet) public {
      require(_goal <= _cap);
  }
  // =============

  // Token Deployment
  // =================
  function createTokenContract() internal returns (MintableToken) {
    return new OgcoinToken(); // Deploys the ERC20 token. Automatically called when crowdsale contract is deployed
  }
  // ==================

  // Crowdsale Stage Management
  // =========================================================

  // Change Crowdsale Stage. Available Options: PreICO, ICO
  function setCrowdsaleStage(uint value) public onlyOwner {

      CrowdsaleStage _stage;

      if (uint(CrowdsaleStage.PreICO) == value) {
        _stage = CrowdsaleStage.PreICO;
      } else if (uint(CrowdsaleStage.ICO) == value) {
        _stage = CrowdsaleStage.ICO;
      }

      stage = _stage;

      if (stage == CrowdsaleStage.PreICO) {
        setCurrentRate(1700); // Ogcoin for 70% of 1000ETH per token
      } else if (stage == CrowdsaleStage.ICO) {
        setCurrentRate(1250);// OGcoing for 20% of 1000ETH per Token
      }
  }

  // Change the current rate
  function setCurrentRate(uint256 _rate) private {
      rate = _rate;
  }

  // ================ Stage Management Over =====================

  // Token Purchase
  // =========================
  function () external payable {
      uint256 tokensThatWillBeMintedAfterPurchase = msg.value.mul(rate);
      if ((stage == CrowdsaleStage.PreICO) && (token.totalSupply() + tokensThatWillBeMintedAfterPurchase > totalTokensForSaleDuringPreICO)) {
        msg.sender.transfer(msg.value); // Refund them
        EthRefunded("PreICO Limit Hit");
        return;
      }

      buyTokens(msg.sender);

      if (stage == CrowdsaleStage.PreICO) {
          totalWeiRaisedDuringPreICO = totalWeiRaisedDuringPreICO.add(msg.value);
      }
  }

  function forwardFunds() internal {
      if (stage == CrowdsaleStage.PreICO) {
          wallet.transfer(msg.value);
          EthTransferred("forwarding funds to wallet");
      } else if (stage == CrowdsaleStage.ICO) {
          EthTransferred("forwarding funds to refundable vault");
          super.forwardFunds();
      }
  }
  // ===========================

  // Finish: Mint Extra Tokens as needed before finalizing the Crowdsale.
  // ====================================================================

  function finish(address _teamFund, address _ecosystemFund, address _bountyFund) public onlyOwner {

      require(!isFinalized);
      uint256 alreadyMinted = token.totalSupply();
      require(alreadyMinted < maxTokens);

      uint256 unsoldTokens = totalTokensForSale - alreadyMinted;
      if (unsoldTokens > 0) {
        tokensForEcosystem = tokensForEcosystem + unsoldTokens;
      }

      token.mint(_teamFund,tokensForTeam);
      token.mint(_ecosystemFund,tokensForEcosystem);
      token.mint(_bountyFund,tokensForBounty);
      finalize();
  }
  // ===============================

  // REMOVE THIS FUNCTION ONCE YOU ARE READY FOR PRODUCTION
  // USEFUL FOR TESTING `finish()` FUNCTION
  function hasEnded() public view returns (bool) {
    return true;
  }
}
