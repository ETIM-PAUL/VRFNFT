import { ethers } from "hardhat";
import {BigIntBuffer} from "bigint-buffer"

async function main() {

  const vrf = await ethers.getContractAt("VRFInterface", "0x61c9ddb7F2ec5B7F97b5b543A5bb3d9575De2950")

  const [add] = await ethers.getSigners()
  const addre = add.address;

  // const impersonateLinkHolder = await ethers.getImpersonatedSigner("0x9d4eF81F5225107049ba08F69F598D97B31ea644")

  // const owner = await vrf.connect(impersonateLinkHolder).owner();
  // console.log(owner);
  // const randomWords = await vrf.connect(add).requestRandomWords()

  const d = 61672127016817726662883638452525087898577816902434073984866629832706730662129n

  const uintValue = BigInt(d);
 
    if (d >= 0n && d <= 4294967295n) {
      // Convert BigInt to UInt (Number)
      const uintValue = BigInt(d);
      return uintValue;
    } else {
      console.error("BigInt value is out of the range of a UInt.");
    }


  const s_script = await vrf.connect(add).s_requests(BigInt(d));


  console.log(s_script);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
})