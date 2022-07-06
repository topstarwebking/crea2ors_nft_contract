const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
  solidityKeccak256,
  splitSignature,
  arrayify,
  hexlify,
  toUtf8Bytes,
  formatEther,
  parseEther,
} = require("ethers/lib/utils");

const { BigNumber } = require("ethers");
describe("Token contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    console.log(owner.address);
    const str = toUtf8Bytes("HHH");

    hashed = solidityKeccak256(["bytes"], [str]);
    const signature = await owner.signMessage(arrayify(hashed));
    const sig = splitSignature(signature);

    const Token = await ethers.getContractFactory("Crea2orsNFT");

    const hardhatToken = await Token.deploy(
      "RJJJJ",
      "J",
      "https://github.com",
      10
    );

    const voucher = {
      tokenId: 0,
      metaUri: "HHH",
      mintCount: 100,
      minPrice: 1,
      initialSupply: 1000,
      royaltyFee: 25,
      royaltyAddress: owner.address,
      signature: sig,
    };

    await (
      await hardhatToken.redeem(addr1.address, voucher, {
        value: ethers.utils.parseEther("0.05"),
      })
    ).wait();
    // const ownerBalance = await hardhatToken.balanceOf(owner.address);

    // expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});
