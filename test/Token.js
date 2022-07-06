const { expect } = require("chai");
const { ethers } = require("hardhat");
describe("Token contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Crea2orsNFT");

    const hardhatToken = await Token.deploy(
      "RJJJJ",
      "J",
      "https://github.com",
      10
    );
    console.log("2 stage");
    const voucher = {
      tokenId: 0,
      metaUri:
        "https://crea2ors.mypinata.cloud/ipfs/QmXYUGpSkcggxfVSTDykz1sGdvaq7gVLvSP5te17hWQr6n",
      mintCount: 100,
      minPrice: 10,
      initialSupply: 1000,
      royaltyFee: 25,
      royaltyAddress: "0xcbd382aC994de5633A348347Cec4AaAF02A2954D",
      traits: { power: "2000" },
      signature:
        "0x4764327f76183f4da242d1852e3a26a9c2d1677d8980d0eaa1ff6f5ed72fea6e6fcd86cf54d855d9e8f38f34fe98ca517dc942206f11ed441a169dce43f7f2231b",
    };
    console.log(voucher);
    // const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.redeem(addr1, voucher)).to.equal(
      "0xcbd382aC994de5633A348347Cec4AaAF02A2954D"
    );
    // expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});
