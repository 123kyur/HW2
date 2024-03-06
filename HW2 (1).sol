// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20{
    address public  master;
    address public censor;
    mapping(address => bool) public blacklist;
    modifier Master(){
        require(msg.sender==master,"Not master");
        _;
    }
    modifier CensorandMaster(){
        require(msg.sender==censor||msg.sender==master,"Not censor or master");
        _;
    }
    constructor() ERC20("ABCDEFG", "ABD"){
        _mint(msg.sender,100000000 *10**decimals());
        master=msg.sender;
        censor=msg.sender;
    }
    function changeMaster(address newMaster) external Master {
        require(newMaster != address(0), "Invalid master address");
        master=newMaster;
    }
    function changeCensor(address newCensor)external Master{
        require(newCensor != address(0), "Invalid censor address");
        censor=newCensor;
    }
    function setBlacklist(address target, bool blacklisted) external CensorandMaster{
        blacklist[target]=blacklisted;
    }
    function transfer(address to, uint256 amount) public override returns (bool) {
        if (blacklist[to]) {
            blacklist[msg.sender] = true; 
        }
        require(!blacklist[msg.sender], "Sender is blacklisted");
        require(!blacklist[to], "Recipient is blacklisted");
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        if (blacklist[to]) {
            blacklist[from] = true; 
        }
        require(!blacklist[from], "Sender is blacklisted");
        require(!blacklist[to], "Recipient is blacklisted");
        return super.transferFrom(from, to, amount);
    }

    function clawBack(address target, uint256 amount) external Master{
            _transfer(target,master , amount);
    }
    function mint(address target, uint256 amount) internal  Master
    {
        _mint(target, amount);
    }
    function burn(address target, uint256 amount)internal  Master{
        _burn(target, amount);
    }
}
