// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./CloneLib.sol";

interface BlockTC {
    function setOwner(address _newOwner) external;
    function addBlockers(address[] calldata _toBlock) external;
    function addBlocker(address _toBlock) external;
    function removeBlockers(address[] calldata _toUnblock) external;
    function removeBlocker(address _toUnblock) external;
}

contract TCBlockerFactory is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    address currentImplementation;
    uint256 public counter;

    mapping(address => uint256) userToIndex;
    mapping(uint256 => address) deployedImplementations;

    EnumerableSet.AddressSet blockedAddresses;


    function nftToDeployedImplementation(address _nft) public view returns (address) {
        uint c = userToIndex[_nft];
        //if (c == 0) return address(0); omitted for gas
        return deployedImplementations[c];
    }
    function nftToNotLarvaLabsIndex(address _nft) public view returns (uint) {
        return userToIndex[_nft];
    }

    function clone(address _user) public returns (uint256) {
        require(userToIndex[_user] == 0, "we already have a NLL for this collection");
        counter++;

        address impl = LibClone.clone(currentImplementation);
        BlockTC(impl).setOwner(msg.sender);

        deployedImplementations[counter] = impl;
        userToIndex[_user] = counter;
        return counter;
    }  

    function addBlockedAddresses(address[] calldata toBlock) external onlyOwner {
         for(uint i = 0; i < toBlock.length; i++) {
            blockedAddresses.add(toBlock[i]);
        }
    }
    function removeBlockedAddresses(address[] calldata toUnblock) external onlyOwner {
         for(uint i = 0; i < toUnblock.length; i++) {
            blockedAddresses.remove(toUnblock[i]);
        }
    }
}