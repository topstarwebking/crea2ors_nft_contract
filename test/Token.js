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
    };

    await (
      await hardhatToken.redeem(addr1.address, voucher, {
        value: ethers.utils.parseEther("0.05"),
      })
    ).wait();

    expect(await hardhatToken._currentTokenID()).to.equal(1);
    expect(await hardhatToken.getCurMintedSupply(0)).to.equal(100);
    expect(await hardhatToken.contractURI()).to.equal("https://github.com");

    await (
      await hardhatToken.redeem(addr1.address, voucher, {
        value: ethers.utils.parseEther("0.05"),
      })
    ).wait();

    expect(await hardhatToken._currentTokenID()).to.equal(1);
    expect(await hardhatToken.getCurMintedSupply(0)).to.equal(200);
    expect(await hardhatToken.balanceOf(addr1.address, 0)).to.equal(200);

    await hardhatToken.connect(addr1).setApprovalForAll(owner.address, true);

    await hardhatToken
      .connect(addr2)
      .transferNFT(0, 50, addr1.address, addr2.address);
    expect(await hardhatToken.balanceOf(addr2.address, 0)).to.equal(50);

    const voucher1 = {
      tokenId: 1,
      metaUri: "HHH",
      mintCount: 200,
      minPrice: 1,
      initialSupply: 1000,
      royaltyFee: 25,
      royaltyAddress: owner.address,
    };

    await (
      await hardhatToken.redeem(addr1.address, voucher1, {
        value: ethers.utils.parseEther("0.05"),
      })
    ).wait();

    expect(await hardhatToken._currentTokenID()).to.equal(2);
    expect(await hardhatToken.getCurMintedSupply(1)).to.equal(200);
  });

  it("This is second mint", async function () {
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

    expect(await hardhatToken._currentTokenID()).to.equal(1);
    expect(await hardhatToken.getCurMintedSupply(0)).to.equal(100);
    expect(await hardhatToken.uri(0)).to.equal("HHH");
    expect(await hardhatToken.contractURI()).to.equal("https://github.com");
  });
});
