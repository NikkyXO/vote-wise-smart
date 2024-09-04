// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Vote.sol";

contract VotingFactory {
    constructor(address _voteContractAddress) {
        voteContractAddress = _voteContractAddress;
    }

    mapping(address => address[]) public votingContracts;
    address private voteContractAddress;

    event VoteContractCreated(address indexed owner, address voteContractAddress);

    function CreateNewVote() public {
        Vote vote = new Vote();
        address voteAddress = address(vote);
        votingContracts[msg.sender].push(voteAddress);
        emit VoteContractCreated(msg.sender, voteAddress);

   }

    // function createVote() external {
    //     address clone = createClone(voteContractAddress);
    //     votingContracts[msg.sender].push(clone);
    //     emit VoteContractCreated(msg.sender, clone);
    // }

    // function createClone(address target) internal returns (address result) {
    //     bytes20 targetBytes = bytes20(target);
    //     assembly {
    //         let clone := mload(0x40)
    //         mstore(clone, 0x3d602d80600a3d3981f3)
    //         mstore(add(clone, 0x14), targetBytes)
    //         mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf3)
    //         result := create(0, clone, 0x37)
    //     }
    // }

    function getVotingContractsByOwner(address owner) external view returns (address[] memory) {
        return votingContracts[owner];
    }

    // cancel vote
}
