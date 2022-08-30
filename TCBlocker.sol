pragma solidity 0.8.10;

contract TCBlocker {

    address receiver;
    address factory;
    mapping(address => bool) blocked;

    receive() external payable {
        require(receiver != address(0), "sanity check");
        require(!blocked[msg.sender], "tc or otherwise blocked");
        payable(receiver).call{value: msg.value}('');
    }
    
    function getReceiver() external view returns (address) {
        return receiver;
    }
    function init(address _receiver, address _factory, address[] calldata blockers) external {
        require(receiver == address(0) && factory == address(0), "only set once");
        receiver = _receiver;
        factory = _factory;
    }

    function transferReceiver(address _newReceiver) external {
        require(msg.sender == factory, "factory only");

        receiver = _newReceiver;
    }

    function addBlockers(address[] calldata _toBlock) internal {
        require(msg.sender == factory, "only owner can block");
        for(uint i; i < _toBlock.length; i++) {
            blocked[_toBlock[i]] = true;
        }
    }
}
