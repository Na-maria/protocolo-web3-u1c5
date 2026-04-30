// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract StakingRewards is Ownable, ReentrancyGuard {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;
    AggregatorV3Interface public immutable ethUsdPriceFeed;

    uint256 public rewardRate = 5;
    uint256 public totalStaked;

    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakeTimestamp;

    event TokensEmStake(address indexed usuario, uint256 quantidade);
    event TokensSacados(address indexed usuario, uint256 quantidade);
    event RecompensaPaga(address indexed usuario, uint256 recompensa);

    constructor(
        address initialOwner,
        address stakingTokenAddress,
        address rewardTokenAddress,
        address priceFeedAddress
    ) Ownable(initialOwner) {
        require(stakingTokenAddress != address(0), "Token de stake invalido");
        require(rewardTokenAddress != address(0), "Token de recompensa invalido");
        require(priceFeedAddress != address(0), "Oraculo invalido");

        stakingToken = IERC20(stakingTokenAddress);
        rewardToken = IERC20(rewardTokenAddress);
        ethUsdPriceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Quantidade precisa ser maior que zero");

        _payReward(msg.sender);

        stakedBalance[msg.sender] += amount;
        stakeTimestamp[msg.sender] = block.timestamp;
        totalStaked += amount;

        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Falha no stake");

        emit TokensEmStake(msg.sender, amount);
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "Quantidade precisa ser maior que zero");
        require(stakedBalance[msg.sender] >= amount, "Saldo em stake insuficiente");

        _payReward(msg.sender);

        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;

        require(stakingToken.transfer(msg.sender, amount), "Falha no saque");

        emit TokensSacados(msg.sender, amount);
    }

    function claimReward() external nonReentrant {
        _payReward(msg.sender);
    }

    function pendingReward(address user) public view returns (uint256) {
        if (stakedBalance[user] == 0 || stakeTimestamp[user] == 0) {
            return 0;
        }

        uint256 secondsStaked = block.timestamp - stakeTimestamp[user];
        uint256 baseReward = (stakedBalance[user] * rewardRate * secondsStaked) / (365 days * 100);
        uint256 multiplier = _oracleMultiplier();

        return (baseReward * multiplier) / 100;
    }

    function latestEthUsdPrice() public view returns (int256) {
        (, int256 answer,,,) = ethUsdPriceFeed.latestRoundData();
        return answer;
    }

    function setRewardRate(uint256 newRewardRate) external onlyOwner {
        require(newRewardRate > 0 && newRewardRate <= 100, "Taxa invalida");
        rewardRate = newRewardRate;
    }

    function _payReward(address user) internal {
        uint256 reward = pendingReward(user);
        stakeTimestamp[user] = block.timestamp;

        if (reward > 0) {
            require(rewardToken.transfer(user, reward), "Falha ao pagar recompensa");
            emit RecompensaPaga(user, reward);
        }
    }

    function _oracleMultiplier() internal view returns (uint256) {
        int256 price = latestEthUsdPrice();
        require(price > 0, "Preco invalido");

        uint256 ethUsd = uint256(price) / 1e8;

        if (ethUsd >= 4000) {
            return 120;
        }

        if (ethUsd >= 2500) {
            return 100;
        }

        return 80;
    }
}
