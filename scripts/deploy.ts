import { ethers } from "hardhat";

async function main() {

  // const subscriptionId =14204;
  // const vrfCoordinator = '0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D';
  // const keyHash =
  //   '0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15';


  const vrfContract = await ethers.deployContract("JOE_GAMING_NFT");

  await vrfContract.waitForDeployment();

  console.log("VRF contract deployed to", vrfContract.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
