const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const BooleanIdentityProvider = artifacts.require("BooleanIdentityProvider");

const IDENTITY_COORDINATOR_ADDR = IdentityCoordinator.address;
const BOOLEAN_IDENTITY_PROVIDER_ADDR = BooleanIdentityProvider.address;

const ACCOUNT = "0x259ddecd8542c7af8e5cb74629c405f11c866e50";

const main = async account => {
  const cost = 0;
  const requestId = Math.floor(Math.random() * 1000000);

  const identityCoordinator = await IdentityCoordinator.at(
    IDENTITY_COORDINATOR_ADDR
  );
  const identityProvider = await BooleanIdentityProvider.at(
    BOOLEAN_IDENTITY_PROVIDER_ADDR
  );

  const { logs: reqLogs } = await identityCoordinator.requestVerification(
    await identityProvider.providerId(),
    "",
    cost,
    requestId,
    { from: account }
  );

  await identityProvider.addPassing(account, requestId);
};

module.exports = cb =>
  main(ACCOUNT)
    .then(res => cb(null, res))
    .catch(err => cb(err));

process.on("unhandledRejection", error => {
  console.log("unhandledRejection", error.stack);
});
