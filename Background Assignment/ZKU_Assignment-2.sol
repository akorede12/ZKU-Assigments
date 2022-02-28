// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
// Assignment 2
/*
Proposalnames:
Ak
0x416b000000000000000000000000000000000000000000000000000000000000

Tame
0x54616d6500000000000000000000000000000000000000000000000000000000

Jiggy
0x4a69676779000000000000000000000000000000000000000000000000000000

chairperson
0xe4a8Fee29653dA8193B25671f2cE597fBa253cFd

voters
1. 0xdD870fA1b7C4700F2BD7f44238821C26f7392148
2. 0x583031D1113aD414F02576BD6afaBfb302140225
3. 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB
4. 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C
5. 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c
6. 0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC
7. 0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C
8. 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7
9. 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678
10. 0x17F6AD8Ef982297579C203069C1DbfFE4348c372

giveRightToVote 
transaction cost: 48657
gas: 80000000
execution cost: 48657

*/

contract Ballot {
   
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }
    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    /** 
     * @dev Create a new ballot to choose one of 'proposalNames'.
     * @param proposalNames names of proposals
     */
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            // 'Proposal({...})' creates a temporary
            // Proposal object and 'proposals.push(...)'
            // appends it to the end of 'proposals'.
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }
    // OnlyOwner modifier to restrict access to function to only the chairperson
    modifier onlyOwner() {
        require(msg.sender == chairperson, "user not authorised");
        _;
    }   
    /** 
     * @dev Give 'voter' the right to vote on this ballot. May only be called by 'chairperson'.
     * @param voter address of voter
     */
     // Only the chairperson can call this function
    function giveRightToVote(address voter) onlyOwner public {
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    /**
     * @dev Delegate your vote to the voter 'to'.
     * @param to address to which vote is delegated
     */
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    /**
     * @dev Give your vote (including votes delegated to you) to proposal 'proposals[proposal].name'.
     * @param proposal index of proposal in the proposals array
     */
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /** 
     * @dev Computes the winning proposal taking all previous votes into account.
     * @return winningProposal_ index of winning proposal in the proposals array
     */
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    /** 
     * @dev Calls winningProposal() function to get the index of the winner contained in the proposals array and then
     * @return winnerName_ the name of the winner
     */
    function winnerName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}
