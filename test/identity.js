const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");

contract("IdentityCoordinator", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let identityCoordinator = null;
  let aba = null;
  let kernel = null;
  let identityProvider = null;
  let nextId = 100;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    identityCoordinator = await IdentityCoordinator.deployed();
    aba = await AbacusToken.deployed();
    kernel = await AbacusKernel.deployed();

    identityProvider = await SandboxIdentityProvider.new(
      kernel.address,
      identityCoordinator.address,
      0
    );

    await identityProvider.registerProvider(
      "Ionia", "Valoran", true
    )

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));
  });

  it("should update the identity if request exists", async () => {
    const params = {
      providerId: await identityProvider.providerId(),
      requestId: 201011,
      cost: 0
    }

    // Make a request
    const { logs: requestCheckLogs } = await kernel.requestService(
      params.providerId,
      params.cost,
      params.requestId
    );
    assert.equal(requestCheckLogs.length, 1);
    assert.equal(requestCheckLogs[0].event, "ServiceRequested");

    // Write data
    const { logs: writeLogs } = await identityProvider.writeBytes32Field(
      accounts[0],
      params.requestId,
      16,
      "0x1"
    );

    const data = await identityCoordinator.bytes32Data(
      params.providerId,
      accounts[0],
      16
    );

    assert(data.includes("1"), "Data should exist in identity provider");
  });

  it("should not update the identity if no request", async () => {
    await identityProvider.writeBytes32Field(accounts[3], 123, 88, "0x1");
    const allowed = await identityCoordinator.bytes32Data(
      await identityProvider.providerId(),
      accounts[3],
      88
    );

    assert(
      !allowed.includes("1"),
      "Should not pass since verification is incomplete"
    );
  });
});
