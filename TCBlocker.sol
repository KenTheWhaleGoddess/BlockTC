pragma solidity 0.8.10;

contract BlockTC {

    address _owner;
    mapping(address => bool) blocked;

    receive() external payable {
        require(_owner != address(0));
        require(!blocked[msg.sender], "tc or otherwise blocked");
        payable(_owner).call{value: msg.value}('');
    }

    function setOwner(address _newOwner) external {
        require(_owner == address(0) || msg.sender == _owner, "only set once");
        _owner = _newOwner;
    }

    function addBlockers(address[] calldata _toBlock) external {
        require(msg.sender == _owner, "only owner can block");
        for(uint i; i < _toBlock.length; i++) {
            addBlocker(_toBlock[i]);
        }
    }

    function removeBlockers(address[] calldata _toUnblock) external {
        require(msg.sender == _owner, "only owner can block");
        for(uint i; i < _toUnblock.length; i++) {
            removeBlocker(_toUnblock[i]);
        }
    }

    function addBlocker(address _toBlock) public {
        require(msg.sender == _owner, "only owner can block");
        blocked[_toBlock] = true;
    }
    function removeBlocker(address _toUnblock) public {
        require(msg.sender == _owner, "only owner can unblock");
        blocked[_toUnblock] = false;
    }
}
