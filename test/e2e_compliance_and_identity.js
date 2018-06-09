const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const AccreditedUSToken = artifacts.require("AccreditedUSToken");

const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");

contract("E2E Compliance and Identity", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let aba = null;
  let kernel = null;

  let identityProvider = null;
  let ctoken = null;

  before(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    aba = await AbacusToken.deployed();
    kernel = await AbacusKernel.deployed();

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));

    identityProvider = await SandboxIdentityProvider.deployed();
    ctoken = await AccreditedUSToken.deployed();
  });

  it("should allow free transaction for both approved by identity provider", async () => {

    const cost = 0;

    await ctoken.request();

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[0]
    });
    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[4]
    });

    const id = await identityProvider.providerId();

    const params = {
      providerId: id,
      cost: 0,
      requestId1: 1234,
      requestId2: 5678,
      expiry: 50
    };

    const { logs: reqLogs1 } = await kernel.requestAsyncService(
      params.providerId,
      params.cost,
      params.requestId1,
      params.expiry,
      { from: accounts[0] }
    );
    assert.equal(reqLogs1.length, 1);
    assert.equal(reqLogs1[0].args.requestId, params.requestId1);

    await identityProvider.writeBytes32Field(
      accounts[0],
      506,
      "0x1"
    );

    const { logs: reqLogs2 } = await kernel.requestAsyncService(
      params.providerId,
      params.cost,
      params.requestId2,
      params.expiry,
      { from: accounts[4] }
    );
    assert.equal(reqLogs2.length, 1);
    assert.equal(reqLogs2[0].args.requestId, params.requestId2);

    await identityProvider.writeBytes32Field(
      accounts[4],
      506,
      "0x1"
    );

    const { logs: xferLogs } = await ctoken.transfer(accounts[4], 100);
    assert.equal(xferLogs.length, 1);
  });
});
