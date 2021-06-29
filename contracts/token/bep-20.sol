pragma solidity ^0.8.0;

import "https://github.com/CrazyNFT/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Timber is ERC20 {
    constructor(uint256 initialSupply) public ERC20("Timber","TIM"){
        _mint(msg.sender,initialSupply);
    }
}
//Amount per new mint cycle: 100000000000000000000000000
