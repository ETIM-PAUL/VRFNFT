import { ethers } from "hardhat";

async function main() {

  const vrf = await ethers.getContractAt("VRFInterface", "0xdB29051641c7257BF8ca45a68B16505C254dC6d1")

  const [add] = await ethers.getSigners()
  const addre = add.address;

  // const impersonateLinkHolder = await ethers.getImpersonatedSigner("0x9d4eF81F5225107049ba08F69F598D97B31ea644")

  // const owner = await vrf.connect(impersonateLinkHolder).owner();

  const d = await vrf.connect(add).requestRandomWords()
  const b = await vrf.connect(add).lastRequestId()

    // console.log(d)
    // console.log(b)
  
    // const s_script = await vrf.connect(add).mintNFT();
    // const s_script = await vrf.connect(add).tokenURI(0);




  // const d = 61672127016817726662883638452525087898577816902434073984866629832706730662129n

  // const b = await ethers.getNumber(k)
  // const b = await ethers.toBeHex(d)

  console.log(b);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
})