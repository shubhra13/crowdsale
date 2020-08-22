pragma solidity ^0.5.0;

import "./PupperCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

// Inherit the crowdsale contracts

contract PupperCoinSale  is Crowdsale, MintedCrowdsale, CappedCrowdsale, RefundablePostDeliveryCrowdsale{

    // PupperCoin pup_token1 = new PupperCoin("test1234", "TXN", 0);
    constructor(
        // Fill in the constructor parameters!
        uint _rate, // rate in TKNbits
        address payable _wallet, // sale beneficiary
        PupperCoin pup_token, // the ArcadeToken itself that the ArcadeTokenSale will work with
        uint _goal,
        uint _open,
        uint _close,
        uint _cap
    ) 
    // Pass the constructor parameters to the crowdsale contracts.
    Crowdsale(_rate, _wallet, pup_token)  RefundableCrowdsale(_goal) TimedCrowdsale(_open, _close) CappedCrowdsale(_cap)
    public {
        require(_goal <= _cap);
        if(!isOpen()) {
            finalize();
        }
       
    }
    
}


contract PupperCoinSaleDeployer {

    // testing: uint fakenow = now;
    address public token_sale_address;
    address public token_address;
    PupperCoinSale puppercoin_sale;


    constructor(
        //Fill in the constructor parameters!
        string memory name, 
        string memory symbol, 
        address payable wallet
    )
    
        public
    {
        // create the PupperCoin and keep its address handy
        PupperCoin token = new PupperCoin(name, symbol, 0);
        
        token_address = address(token);
        uint goal = 2 ether;
        uint cap = 50 ether;
        
        
        
        // testing: uint open = fakenow;
        uint open = now;
        
        // testing: uint close = fakenow + 2 minutes;
        uint close = now + 24 weeks;
        

        // create the PupperCoinSale and tell it about the token, set the goal, and set the open and close times to now and now + 24 weeks.
        puppercoin_sale = new PupperCoinSale(1, wallet, token, goal, open, close, cap);
        token_sale_address = address(puppercoin_sale);
        
        // make the PupperCoinSale contract a minter, then have the PupperCoinSaleDeployer renounce its minter role
        token.addMinter(token_sale_address);
        token.renounceMinter();
    }
    
    // testing: function fastforward() public {
    //     fakenow += 10 minutes;
    // }
    
    
    function goalReached() public view returns (bool) {
        return  puppercoin_sale.goalReached();
    }
    
     function finalizeTheDeal() public returns(bool){
        
        puppercoin_sale.finalize();
        return puppercoin_sale.finalized();
    }
    
    function isCampaignOpen() public view returns (bool){
        return puppercoin_sale.isOpen();
    }
    
    function withdrawTokensToBeneficiary() public {
        puppercoin_sale.withdrawTokens(msg.sender);
    }
    
    function claimRefund(address payable beneficiary) public  
    {
        puppercoin_sale.claimRefund(beneficiary);
    }
    
}
