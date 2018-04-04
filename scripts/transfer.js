const SampleCompliantToken = artifacts.require("SampleCompliantToken");

const ACCOUNT = "0x259ddecd8542c7af8e5cb74629c405f11c866e50";

const main = async (from, to, amount) => {
  const token = await SampleCompliantToken.deployed();
  await token.transfer(to, amount);
};

module.exports = cb =>
  main(ACCOUNT, "0x63fae14b601c83120704d37a7f78eb65057dd615", 10)
    .then(res => cb(null, res))
    .catch(err => cb(err));

process.on("unhandledRejection", error => {
  console.log("unhandledRejection", error.stack);
});
