const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const BooleanIdentityProvider = artifacts.require("BooleanIdentityProvider");

const IDENTITY_COORDINATOR_ADDR = "0x212cb0ce7da0334166092b782f456a8ab33c9e6f";
const BOOLEAN_IDENTITY_PROVIDER_ADDR =
  "0x72b780c66f71e203cd50f77908854bcaffec2e86";
const ACCOUNT = "0x259ddecd8542c7af8e5cb74629c405f11c866e50";

const main = async () => {
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
    { from: ACCOUNT }
  );

  await identityProvider.addPassing(ACCOUNT, requestId);
};

module.exports = cb =>
  main()
    .then(res => cb(null, res))
    .catch(err => cb(err));

process.on("unhandledRejection", error => {
  console.log("unhandledRejection", error.stack);
});
