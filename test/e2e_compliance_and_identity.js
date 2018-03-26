const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");
const BooleanIdentityProvider = artifacts.require("BooleanIdentityProvider");
const BooleanIdentityComplianceStandard = artifacts.require(
  "BooleanIdentityComplianceStandard"
);

contract("E2E", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let identityCoordinator = null;
  let aba = null;
  let kernel = null;

  let identityProvider = null;
  let complianceStandard = null;
  let ctoken = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.new();
    complianceCoordinator = await ComplianceCoordinator.new(
      providerRegistry.address
    );
    identityCoordinator = await IdentityCoordinator.new(
      providerRegistry.address
    );
    aba = await AbacusToken.new();
    kernel = await AbacusKernel.new(
      aba.address,
      providerRegistry.address,
      complianceCoordinator.address,
      identityCoordinator.address
    );

    await complianceCoordinator.setKernel(kernel.address);
    await identityCoordinator.setKernel(kernel.address);
    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));

    identityProvider = await BooleanIdentityProvider.new(
      identityCoordinator.address,
      0
    );
    await identityProvider.registerProvider("Boolean", "");
    complianceStandard = await BooleanIdentityComplianceStandard.new(
      providerRegistry.address,
      0,
      await identityProvider.providerId()
    );
    await complianceStandard.registerProvider("BooleanId", "");

    ctoken = await SampleCompliantToken.new(
      complianceCoordinator.address,
      await complianceStandard.providerId()
    );
  });

  it("should allow transaction for both approved by identity provider", async () => {
    const requestId1 = 1234;
    const requestId2 = 5678;
    const cost = 0;

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[0]
    });
    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[4]
    });

    const { logs: reqLogs1 } = await identityCoordinator.requestVerification(
      await identityProvider.providerId(),
      "",
      cost,
      requestId1,
      { from: accounts[0] }
    );
    assert.equal(reqLogs1.length, 1);
    assert.equal(reqLogs1[0].args.requestId, requestId1);

    await identityProvider.addPassing(accounts[0], requestId1);

    const { logs: reqLogs2 } = await identityCoordinator.requestVerification(
      await identityProvider.providerId(),
      "",
      cost,
      requestId2,
      { from: accounts[4] }
    );
    assert.equal(reqLogs2.length, 1);
    assert.equal(reqLogs2[0].args.requestId, requestId2);

    await identityProvider.addPassing(accounts[4], requestId2);

    const { logs: xferLogs } = await ctoken.transfer(accounts[4], 100);
    assert.equal(xferLogs.length, 1);
  });
});
