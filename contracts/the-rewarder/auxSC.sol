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

interface ITRP {
    function deposit(uint256 amount) external;
}

contract auxSC{

    address liquidityToken;
    address flashLoanerPool;
    address theRewarderPool;
    
    address deployer;


    constructor (address liquidityToken_, address flashLoanerPool_,address theRewarderPool_){
        deployer = msg.sender;
        liquidityToken = liquidityToken_;
        flashLoanerPool = flashLoanerPool_;
        theRewarderPool = theRewarderPool_;
    }


    function exploitFlashLoan(uint amount_) public {

        // Hago el llamado al metodo flashLoan del pool 
        IFLP(flashLoanerPool).flashLoan(amount_);

    }

    //! Metedo llamado desde el pool al llamar a flashLoan
    function receiveFlashLoan(uint256 amount_) public{

        //! obtengo el dinero solicitado
        //! tengo que hacer algo con el prestamo

        //uint256 aux = amount_/2;
        //ITRP(theRewarderPool).deposit(aux);
        //ITRP(theRewarderPool).deposit(aux);

        // retorno el dinero del prestamo 
        IERC20(liquidityToken).transferFrom(address(this),flashLoanerPool,amount_);

    }


}