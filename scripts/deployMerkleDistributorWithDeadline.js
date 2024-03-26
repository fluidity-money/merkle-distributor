require('dotenv').config()
require('@nomiclabs/hardhat-ethers')
const { ethers } = require('hardhat')

async function main() {
  const MerkleDistributorWithDeadline = await ethers.getContractFactory('MerkleDistributorWithDeadline')
  const merkleDistributorWithDeadline = await MerkleDistributorWithDeadline.deploy(
    // FLY token
    '0x000F1720A263f96532D1ac2bb9CDC12b72C6f386',
    // staking contract
    '0x0000000000000000000000000000000000000000',
    // merkle root
    '0xcbf305713016aab955877565fd0d0bf95f3cf274d21752dc82b327e0d197a028',
    // latest timestamp
    1791358941
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
