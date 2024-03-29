// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import {IMerkleDistributor} from "./interfaces/IMerkleDistributor.sol";
import {IStakingForAnother} from "./interfaces/IStakingForAnother.sol";

error AlreadyClaimed();
error InvalidProof();

contract MerkleDistributor is IMerkleDistributor {
    using SafeERC20 for IERC20;

    address public immutable override token;
    bytes32 public immutable override merkleRoot;

    // Staking contract is used to send the amounts with the #stakeFor function.
    address public immutable stakingContract;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(address token_, address stakingContract_, bytes32 merkleRoot_) {
        token = token_;
        stakingContract = stakingContract_;
        merkleRoot = merkleRoot_;
    }

    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function _verifyAndSet(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) private {
        if (isClaimed(index)) revert AlreadyClaimed();

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node)) revert InvalidProof();

        _setClaimed(index);
    }

    function claim(uint256 index, uint256 amount, bytes32[] calldata merkleProof)
        public
        virtual
        override
    {
        _verifyAndSet(index, msg.sender, amount, merkleProof);
        IERC20(token).safeTransfer(msg.sender, amount);
        emit Claimed(index, msg.sender, amount);
    }

    function claimAndStake(uint256 index, uint256 amount, bytes32[] calldata merkleProof)
        public
        virtual
    {
        _verifyAndSet(index, msg.sender, amount, merkleProof);
        IERC20(token).safeApprove(stakingContract, amount);
        IStakingForAnother(stakingContract).stakeFor(msg.sender, amount);
        emit ClaimedAndStaked(index, msg.sender, amount);
    }
}
