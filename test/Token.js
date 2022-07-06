const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
  solidityKeccak256,
  splitSignature,
  arrayify,
  hexlify,
  toUtf8Bytes,
} = require("ethers/lib/utils");

describe("Token contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    console.log(owner.address);
    const str = toUtf8Bytes(
      "https://crea2ors.mypinata.cloud/ipfs/QmXYUGpSkcggxfVSTDykz1sGdvaq7gVLvSP5te17hWQr6n"
    );
    hashed = solidityKeccak256(["bytes"], [str]);
    console.log(hashed);
    const signature = await owner.signMessage(hashed);
    console.log("signature", signature);
    //  const { r, s, v } = splitSignature(signature);

    const Token = await ethers.getContractFactory("Crea2orsNFT");

    const hardhatToken = await Token.deploy(
      "RJJJJ",
      "J",
      "https://github.com",
      10
    );

    const voucher = {
      tokenId: 0,
      metaUri:
        "https://crea2ors.mypinata.cloud/ipfs/QmXYUGpSkcggxfVSTDykz1sGdvaq7gVLvSP5te17hWQr6n",
      mintCount: 100,
      minPrice: 10,
      initialSupply: 1000,
      royaltyFee: 25,
      royaltyAddress: owner.address,
      signature: signature,
    };

    console.log(
      await (await hardhatToken.redeem(addr1.address, voucher)).wait()
    );
    // const ownerBalance = await hardhatToken.balanceOf(owner.address);

    // expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});
