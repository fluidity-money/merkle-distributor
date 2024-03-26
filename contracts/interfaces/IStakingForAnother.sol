// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

interface IStakingForAnother {
    function stakeFor(address account, uint256 amount) external returns (uint256 day1Points);
}
