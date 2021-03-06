const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const IdentityToken = artifacts.require("IdentityToken");
const AccreditedUSCS = artifacts.require("AccreditedUSCS");
const AccreditedUSToken = artifacts.require("AccreditedUSToken");

const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");

contract("E2E Compliance and Identity", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;

  let identityProvider = null;
  let USCS = null;
  let ctoken = null;

  before(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    identityToken = await IdentityToken.deployed();

    identityProvider = await SandboxIdentityProvider.new(
      providerRegistry.address,
      identityToken.address,
      0
    );

    await identityProvider.registerProvider(
      "sandbox",
      "www.identityprovider.com",
      true
    );

    USCS = await AccreditedUSCS.new(
      identityToken.address,
      providerRegistry.address,
      0,
      await identityProvider.providerId()
    );

    await USCS.registerProvider("USCS", "AccreditedUSInvestor Check", false);

    ctoken = await AccreditedUSToken.new(
      complianceCoordinator.address,
      await USCS.providerId()
    );
  });

  it("should allow free transaction for both approved by identity provider", async () => {
    const cost = 0;

    const id = await identityProvider.providerId();

    const params = {
      providerId: id,
      cost: 0,
      requestId1: 1234,
      requestId2: 5678,
      expiry: 50
    };

    await identityProvider.writeIdentityBytes32Field(accounts[0], 506, "0x1");

    await identityProvider.writeIdentityBytes32Field(accounts[4], 506, "0x1");

    const { logs: xferLogs } = await ctoken.transfer(accounts[4], 100);
    assert.equal(xferLogs.length, 1);
  });
});
