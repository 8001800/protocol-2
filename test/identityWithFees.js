const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const IdentityCoordinator = artifacts.require("IdentityCoordinator");
const SampleCompliantToken = artifacts.require("SampleCompliantToken");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const AbacusToken = artifacts.require("AbacusToken");
const AbacusKernel = artifacts.require("AbacusKernel");
const { promisify } = require("es6-promisify");
const BigNumber = require("bignumber.js");
const SandboxIdentityProvider = artifacts.require("SandboxIdentityProvider");
const ethInWei = 1000000000000000000;

contract("IdentityCoordinator", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let identityCoordinator = null;
  let aba = null;
  let kernel = null;
  let identityProvider = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    identityCoordinator = await IdentityCoordinator.deployed();
    aba = await AbacusToken.deployed();
    kernel = await AbacusKernel.deployed();

    identityProvider = await SandboxIdentityProvider.deployed();

    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1));
    await aba.approve(kernel.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[3]
    });
  });

  it("should update the identity if request exists", async () => {
    //transfer aba tokens to account3
    await aba.transfer(accounts[3], new BigNumber(20 * ethInWei));

    const requestId = 1289479214;
    const cost = new BigNumber(4 * ethInWei);

    const { logs: reqLogs } = await identityCoordinator.requestVerification(
      await identityProvider.providerId(),
      cost,
      requestId,
      10,
      { from: accounts[3] }
    );

    //check if fees are escrowed
    const amountEscrowed = await aba.balanceOf(kernel.address);
    assert.equal(reqLogs.length, 1);
    assert.equal(reqLogs[0].args.requestId, requestId);
    assert.equal(amountEscrowed.toNumber(), cost.toNumber());

    await identityProvider.writeBytes32Field(
      accounts[3],
      requestId,
      123,
      "0x1"
    );

    //check if identity provider recieved fees
    const identityProviderId = await identityProvider.providerId();
    const abaBalanceIdentityProvider = await aba.balanceOf(
      await providerRegistry.providerOwner(identityProviderId.toNumber())
    );
    assert.equal(abaBalanceIdentityProvider.toNumber(), cost.toNumber());

    const allowed = await identityCoordinator.bytes32Data(
      identityProviderId,
      accounts[3],
      88
    );
    assert(allowed.includes("1"), "Should be allowed in identity provider");
  });
});
