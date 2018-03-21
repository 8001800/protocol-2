const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");

contract("ComplianceCoordinator", accounts => {
  it("should work", async () => {
    const providerRegistry = await ProviderRegistry.new();
    const complianceCoordinator = await ComplianceCoordinator.new(
      providerRegistry.address
    );
  });
});
