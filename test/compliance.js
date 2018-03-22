const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const ComplianceStandardToken = artifacts.require("ComplianceStandardToken");
const WhitelistStandard = artifacts.require("WhitelistStandard");
const { promisify } = require("es6-promisify");

contract("ComplianceCoordinator", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.new();
    complianceCoordinator = await ComplianceCoordinator.new(
      providerRegistry.address
    );
  });

  it("should allow registry", async () => {
    const standard = await WhitelistStandard.new(providerRegistry.address, 0);
    const registerTx = await standard.registerProvider("Whitelist", "");

    const events = await promisify(cb =>
      providerRegistry.ProviderInfoUpdate().get(cb)
    )();
    const id = await standard.providerId();
    const owner = await providerRegistry.providerOwner(id);

    // Ensure owner is same
    assert.equal(events[0].args.owner, owner);

    // Create token using list standard
    const token = await ComplianceStandardToken.new(
      complianceCoordinator.address,
      id.toString()
    );

    // Authorize account 2 on list standard
    await standard.allow(accounts[2]);

    await token.transfer(accounts[1], 10);
    await token.transfer(accounts[2], 10);
    const balance1 = await token.balanceOf(accounts[1]);
    const balance2 = await token.balanceOf(accounts[2]);

    assert.equal(balance1, 0);
    assert.equal(balance2, 10);
  });
});
