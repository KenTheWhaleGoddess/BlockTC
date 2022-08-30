// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./CloneLib.sol";

interface BlockTC {
    function init(address _receiver, address _factory, address[] calldata blockers) external;
    function transferReceiver(address _newReceiver) external;

    function getReceiver() external view returns (address);
}

contract TCBlockerFactory is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    address currentImplementation;

    EnumerableSet.AddressSet blockedAddresses;
    EnumerableSet.AddressSet impls;


    function getBlockedAddresses() external view returns (address[] memory) {
        return blockedAddresses.values();
    }

    function cloneForMe() public returns (address) {
        address impl = LibClone.clone(currentImplementation);
        BlockTC(impl).init(msg.sender, address(this), blockedAddresses.values());
        impls.add(impl);
        return impl;
    }  

    function transferReceiverFrom(address _newUser, address impl) external {
        require(BlockTC(impl).getReceiver() == msg.sender, "User not receiver");
        BlockTC(impl).transferReceiver(_newUser);
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
