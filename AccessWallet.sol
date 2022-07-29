// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./MyWallet.sol";
import "./AccessControl.sol";

contract AccessWallet is AccessControl {
    using SafeMath for uint256;

    MyWallet _walletInterface;

    /**
     * @dev Contract constructor instantiates wallet interface and sets msg.sender to admin
     */
    constructor(MyWallet _wallet, address[] memory _owners) AccessControl(_owners){
        _walletInterface = MyWallet(_wallet);
        admin = msg.sender;
    }

    /*
     * Blockchain get functions
     */

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getAdmin() external view returns (address) {
        return admin;
    }
}
