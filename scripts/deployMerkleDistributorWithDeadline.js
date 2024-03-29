require('dotenv').config()
require('@nomiclabs/hardhat-ethers')
const { ethers } = require('hardhat')

async function main() {
  const MerkleDistributorWithDeadline = await ethers.getContractFactory('MerkleDistributorWithDeadline')
  const merkleDistributorWithDeadline = await MerkleDistributorWithDeadline.deploy(
    // FLY token
    '0x000F1720A263f96532D1ac2bb9CDC12b72C6f386',
    // staking contract
    '0x9E8892E443AD6472e4D9362DF6D0C238000028a3',
    // merkle root
    '0x6f506a82a58736e1f65f2c9be6ecdc9924cb9462f25f1641bc5bb1e62e8a1b0b',
    // last timestamp (2nd of may 2pm UTC)
    1714608000.0
  )
  await merkleDistributorWithDeadline.deployed()
  console.log(`merkleDistributorWithDeadline deployed at ${merkleDistributorWithDeadline.address}`)
}

main()
  // eslint-disable-next-line no-process-exit
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    // eslint-disable-next-line no-process-exit
    process.exit(1)
  })
