async function main() {
  const [deployer] = await ethers.getSigners();

  const Token = await ethers.getContractFactory("Crea2ors_Manager");
  const token = await Token.deploy();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
