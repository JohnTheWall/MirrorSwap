pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract MirrorSwap {
    
    // ============ State Variables ============
    
    // Trade States
    address public MakerAsset;
    address public TakerAsset;
    uint256 public MakerAssetAmount;
    uint256 public TakerAssetAmount;
    
    // Wallet Actors
    address payable public MakerWalletAddress;
    address payable public TakerWalletAddress;
    
    // swap revert timestamp
    uint256 public RevertTimestamp;
    
    // swap complete bool
    bool public swapComplete;
    
    // ============ Constructor ============

    constructor(
        address makerAsset,
        address takerAsset,
        uint256 makerAssetAmount,
        uint256 takerAssetAmount, 
        uint256 revertTimeSeconds
    )
        public
    {
        MakerAsset = makerAsset;
        TakerAsset = takerAsset;
        MakerAssetAmount = makerAssetAmount;
        TakerAssetAmount = takerAssetAmount;
        MakerWalletAddress = msg.sender;
        RevertTimestamp = now +  revertTimeSeconds;
        swapComplete = false;
        
        ERC20(MakerAsset).approve(address(this), makerAssetAmount*10);
    }
    
    // Deposit Maker Asset 
    function depositMakerAsset(       
    ) 
        public
        payable
        returns (uint256)
    {    
        if (MakerAsset == 0x0000000000000000000000000000000000000000){
            require(msg.value == MakerAssetAmount, "ETH#deposit: DEPOSIT_NOT_EXACT");
        }else{
            ERC20(MakerAsset).transferFrom(msg.sender, address(this), MakerAssetAmount); 
        }
        return 1;
        
    }
    
    // Swap for Taker Asset 
    function swapTakerAsset(     
    ) 
        public
        payable
        returns (uint256)
    {
        TakerWalletAddress = msg.sender;
        if (TakerAsset == 0x0000000000000000000000000000000000000000){
            require(msg.value == TakerAssetAmount, "ETH not swaped in exact amount");
            MakerWalletAddress.transfer(msg.value);
            ERC20(MakerAsset).transferFrom(address(this), msg.sender, MakerAssetAmount); 
        }else if (MakerAsset == 0x0000000000000000000000000000000000000000){
            ERC20(TakerAsset).transferFrom(msg.sender, MakerWalletAddress, TakerAssetAmount); 
            msg.sender.transfer(MakerAssetAmount);
        }else{
            ERC20(TakerAsset).transferFrom(msg.sender, MakerWalletAddress, TakerAssetAmount);
            ERC20(MakerAsset).transferFrom(address(this), TakerWalletAddress, MakerAssetAmount); 
        }
        
        swapComplete = true;
        return 1;
        
    }
    
    // Cancel swap
    function cancelSwap(     
    ) 
        public
        payable
        returns (uint256)
    {
        if (now > RevertTimestamp && swapComplete == false) {
            if (TakerAsset == 0x0000000000000000000000000000000000000000){
                MakerWalletAddress.transfer(MakerAssetAmount);
            }else{
                ERC20(MakerAsset).transferFrom(address(this), MakerWalletAddress, MakerAssetAmount); 
            }
        }
        
        return 1;
        
    }
    
    
}