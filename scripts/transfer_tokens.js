const AbacusToken = artifacts.require("AbacusToken");

const newOwner = "0x7378668ce54914b2df322fba26003cd48bdf95da";

const main = async () => {
  const token = await AbacusToken.deployed();
  await token.transfer(newOwner, "1000000000000000000000000000"); // 1 billion ABA
  console.log("Tokens transferred.");
};

module.exports = cb => {
  main()
    .then(res => cb(null, res))
    .catch(err => cb(err));
};
