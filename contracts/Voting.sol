// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        string name;
        uint voteCount;
    }

    struct Voter {
        bool voted;
        uint vote;
    }

    address public electionCommissioner;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;

    constructor(string[] memory candidateNames) {
        electionCommissioner = msg.sender;
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }

    function registerVoter(address voter) public {
        require(msg.sender == electionCommissioner, "Only election commissioner can register voters.");
        require(!voters[voter].voted, "The voter is already registered.");
        voters[voter].voted = false;
    }

    function vote(uint candidate) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        require(candidate < candidates.length, "Invalid candidate.");

        sender.voted = true;
        sender.vote = candidate;
        candidates[candidate].voteCount += 1;
    }

    function winningCandidate() public view returns (uint winningCandidate_) {
        uint winningVoteCount = 0;
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidate_ = i;
            }
        }
    }

    function winnerName() public view returns (string memory winnerName_) {
        winnerName_ = candidates[winningCandidate()].name;
    }
}
