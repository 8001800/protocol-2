const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const ListStandard = artifacts.require("ListStandard");
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
    const standard = await ListStandard.new(providerRegistry.address, 0);
    const registerTx = await standard.registerProvider("List", "");

    const events = await promisify(cb =>
      providerRegistry.ProviderInfoUpdate().get(cb)
    )();
    const id = await standard.providerId();
    const owner = await providerRegistry.providerOwner(id);

    assert.equal(events[0].args.owner, owner);
  });
});
