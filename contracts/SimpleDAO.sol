// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleDAO is Ownable {
    IERC20 public immutable governanceToken;
    uint256 public proposalCount;
    uint256 public minimumTokensToPropose;

    struct Proposal {
        string description;
        uint256 deadline;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint256 indexed proposalId, string description, uint256 deadline);
    event VoteCast(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId, bool approved);

    constructor(address initialOwner, address tokenAddress, uint256 minimumTokens)
        Ownable(initialOwner)
    {
        require(tokenAddress != address(0), "Token invalido");
        governanceToken = IERC20(tokenAddress);
        minimumTokensToPropose = minimumTokens;
    }

    function createProposal(string memory description, uint256 durationInSeconds)
        external
        returns (uint256)
    {
        require(bytes(description).length > 0, "Descricao obrigatoria");
        require(durationInSeconds >= 1 hours, "Duracao minima de 1 hora");
        require(
            governanceToken.balanceOf(msg.sender) >= minimumTokensToPropose,
            "Saldo insuficiente para propor"
        );

        proposalCount++;
        proposals[proposalCount] = Proposal({
            description: description,
            deadline: block.timestamp + durationInSeconds,
            votesFor: 0,
            votesAgainst: 0,
            executed: false
        });

        emit ProposalCreated(proposalCount, description, block.timestamp + durationInSeconds);
        return proposalCount;
    }

    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];

        require(proposal.deadline > 0, "Proposta inexistente");
        require(block.timestamp <= proposal.deadline, "Votacao encerrada");
        require(!hasVoted[proposalId][msg.sender], "Usuario ja votou");

        uint256 weight = governanceToken.balanceOf(msg.sender);
        require(weight > 0, "Sem poder de voto");

        hasVoted[proposalId][msg.sender] = true;

        if (support) {
            proposal.votesFor += weight;
        } else {
            proposal.votesAgainst += weight;
        }

        emit VoteCast(proposalId, msg.sender, support, weight);
    }

    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];

        require(proposal.deadline > 0, "Proposta inexistente");
        require(block.timestamp > proposal.deadline, "Votacao ainda aberta");
        require(!proposal.executed, "Proposta ja executada");

        proposal.executed = true;
        bool approved = proposal.votesFor > proposal.votesAgainst;

        emit ProposalExecuted(proposalId, approved);
    }

    function setMinimumTokensToPropose(uint256 minimumTokens) external onlyOwner {
        minimumTokensToPropose = minimumTokens;
    }
}
