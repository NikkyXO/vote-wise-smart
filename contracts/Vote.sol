// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Vote {

    uint256 public  expiresAt;
    bool public started;
    bool public ended;
    address public verifier;
    string public category;
    string public description;
    

    // userHash is key
    mapping (bytes32 => Voter) private verifiedVoters;

    // candidate partyCode is key
    mapping(string => Candidate) public candidates;

    string[] public candidateList;


    error VoterAlreadyVerified(bytes32 userHash);
    error InvalidVoter(bytes32 userHash);
    error CandidateDoesNotExist();
    error DuplicateVoting();
    error VotingAlreadyStarted();
    error VotingAlreadyEnded();
    error VotingNotYetStarted();
    error VotingNotYetEnded();
    error VoterNotYetVerified();
    error CandidateAlreadyRegistered();
    error VotingNotEnded(string message);

     struct Candidate {
        string fullname;
        string partyName;
        string imageIpfsUrl;
        uint256 voteCount;
    }

    struct Voter {
        bool hasVoted;
        bool isVerified;
    }


    event VoterVerified(bytes32 indexed userHash);
    event CandidateAdded(string name, string partyName, string imageIpfsUrl);
    event VoteSuccesful(bytes32 indexed userHash);
    event VotingStarted(string message);
    event VotingEnded(string message);
    event VoteDescriptionSet();


    function setVoteCategoryDescription(string memory _category, string memory _description) external {
        category = _category;
        description = _description;
        emit VoteDescriptionSet();

    }
    

    function addVerifiedVoter(bytes32 _userHash) external {
        if(verifiedVoters[_userHash].isVerified) {
            revert VoterAlreadyVerified(_userHash);
        }
        Voter memory voter = Voter({ isVerified: true, hasVoted: false });
        verifiedVoters[_userHash] = voter;
        emit VoterVerified(_userHash);
    }

    
   function isVoterVerified(bytes32 _userHash) external view returns (bool) {
        return verifiedVoters[_userHash].isVerified;
    }

    function storeCandidate(string calldata _fullname, string calldata _partyName, string calldata _url) external {
        if (bytes(candidates[_partyName].fullname).length != 0) {
            revert CandidateAlreadyRegistered();
        }
        Candidate memory candidate = Candidate({ fullname: _fullname, partyName: _partyName, imageIpfsUrl: _url, voteCount: 0});
        candidates[_partyName] = candidate;
        candidateList.push(_partyName);
        emit CandidateAdded(_fullname, _partyName, _url);
    }

    function updateVote(bytes32 _userHash, string memory _partyName) internal {
        if (bytes(candidates[_partyName].fullname).length == 0) {
        revert CandidateDoesNotExist();
        }
        if (verifiedVoters[_userHash].hasVoted) {
            revert DuplicateVoting();
        }

        verifiedVoters[_userHash].hasVoted = true;
        candidates[_partyName].voteCount += 1;
    }

    function startVotingProcess(uint256 _duration) external {
         if (started) {
            revert VotingAlreadyStarted();
        }
        expiresAt = block.timestamp + _duration * 1 minutes;
        started = true;
        emit VotingStarted('Voting has started');

    }

    function getCollatedVotes() external view returns(Candidate[] memory) {
        if (!ended) {
        revert VotingNotEnded('Voting has not ended');
        }
        Candidate[] memory allCandidates = new Candidate[](candidateList.length);
        for (uint256 i = 0; i < candidateList.length; i++) {
            allCandidates[i] = candidates[candidateList[i]];
        }

        return allCandidates;

    }

    function endVotingProcess() external {
        if (!started) {
            revert VotingNotYetStarted();
        }
        if (block.timestamp < expiresAt) {
            revert VotingNotYetEnded();
        }
        if (ended) {
            revert VotingAlreadyEnded();
        }
        ended = true;
        emit VotingEnded('Voting has ended');

    }



    function vote(bytes32 _userHash, string memory _partyName) external {
        if (!started) {
        revert VotingNotYetStarted();
        }
        if (verifiedVoters[_userHash].hasVoted) {
            revert DuplicateVoting();
        }
        if (bytes(candidates[_partyName].fullname).length == 0) {
            revert CandidateDoesNotExist();
        }
        
        updateVote(_userHash, _partyName);
        emit VoteSuccesful(_userHash);
    }
    

}