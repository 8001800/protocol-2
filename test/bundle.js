//import expectThrow from "openzeppelin-solidity/test/helpers/expectThrow";

const chai = require("chai").use(require("chai-as-promised"));
const assert = chai.assert;

const ProviderRegistry = artifacts.require("ProviderRegistry");
const ComplianceCoordinator = artifacts.require("ComplianceCoordinator");
const Bundle = artifacts.require("Bundle");
const SampleNFT = artifacts.require("SampleNFT");
const SampleToken = artifacts.require("SampleToken");
const BigNumber = require("bignumber.js");

contract("Bundle", accounts => {
  let providerRegistry = null;
  let complianceCoordinator = null;
  let bundle = null;
  let NFT1 = null;
  let NFT2 = null;
  let token1 = null;
  let token2 = null;
  let bundle1 = null;

  beforeEach(async () => {
    providerRegistry = await ProviderRegistry.deployed();
    complianceCoordinator = await ComplianceCoordinator.deployed();
    bundle = await Bundle.deployed();

    // Create NFTs
    NFT1 = await SampleNFT.new(1);
    NFT2 = await SampleNFT.new(2);

    // Create Tokens
    token1 = await SampleToken.new("Token 1");
    token2 = await SampleToken.new("Token 2");

    // Mint NFTs
    await NFT1.mint(accounts[1]);
    await NFT1.mint(accounts[2]);
    await NFT2.mint(accounts[1]);
    await NFT2.mint(accounts[2]);

    // Approve NFTs to Bundle Contract
    await NFT1.approve(bundle.address, 0, { from: accounts[1] });

    await NFT1.approve(bundle.address, 1, { from: accounts[2] });

    await NFT2.approve(bundle.address, 0, { from: accounts[1] });

    await NFT2.approve(bundle.address, 1, { from: accounts[2] });

    // Distribute Tokens
    await token1.transfer(accounts[3], 1000);
    await token1.transfer(accounts[4], 1000);
    await token2.transfer(accounts[3], 1000);
    await token2.transfer(accounts[4], 1000);

    // Approve Bundle Contract
    await token1.approve(bundle.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[3]
    });

    await token1.approve(bundle.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[4]
    });

    await token2.approve(bundle.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[3]
    });

    await token2.approve(bundle.address, new BigNumber(2).pow(256).minus(1), {
      from: accounts[4]
    });
  });

  it("should create bundle", async () => {
    const params = {
      uri: "Asuna",
      complianceProviderId: 0
    };

    // Create Bundle
    const { logs } = await bundle.create(
      params.uri,
      params.complianceProviderId
    );
    bundle1 = logs[1].args.bundleId.toNumber();
    var owner = await bundle.ownerOf(bundle1);
    assert.equal(logs.length, 2);
    assert.equal(logs[1].event, "Create");
    assert.equal(bundle1, 1);
    assert.equal(owner, accounts[0]);
  });

  it("deposit tokens to bundle", async () => {
    const { logs: depToken1Logs } = await bundle.depositERC20Asset(
      bundle1,
      token1.address,
      100,
      {
        from: accounts[3]
      }
    );

    var token1InBundle = await bundle.erc20Assets(bundle1, token1.address);
    assert.equal(token1InBundle, 100);
    assert.equal(depToken1Logs.length, 2);
    assert.equal(depToken1Logs[1].event, "DepositERC20");
    assert.equal(depToken1Logs[1].args.bundleId.toNumber(), bundle1);
    assert.equal(depToken1Logs[1].args.token, token1.address);
    assert.equal(depToken1Logs[1].args.amount, 100);

    const { logs: depToken2Logs } = await bundle.depositERC20Asset(
      bundle1,
      token2.address,
      200,
      {
        from: accounts[4]
      }
    );

    var token2InBundle = await bundle.erc20Assets(bundle1, token2.address);
    assert.equal(token2InBundle, 200);
    assert.equal(depToken2Logs.length, 2);
    assert.equal(depToken2Logs[1].event, "DepositERC20");
    assert.equal(depToken2Logs[1].args.bundleId.toNumber(), bundle1);
    assert.equal(depToken2Logs[1].args.token, token2.address);
    assert.equal(depToken2Logs[1].args.amount, 200);

    var t1BundleBalance = await token1.balanceOf(bundle.address);
    assert.equal(t1BundleBalance.toNumber(), 100);

    await bundle.depositERC20Asset(bundle1, token1.address, 400, {
      from: accounts[4]
    });

    var token1InBundle = await bundle.erc20Assets(bundle1, token1.address);
    assert.equal(token1InBundle, 500);

    t1BundleBalance = await token1.balanceOf(bundle.address);
    assert.equal(t1BundleBalance.toNumber(), 500);
    var t2BundleBalance = await token2.balanceOf(bundle.address);
    assert.equal(t2BundleBalance.toNumber(), 200);
  });

  it("deposit NFT to Bundle", async () => {
    var acc1NFT1Id = await NFT1.tokenOfOwnerByIndex(accounts[1], 0);

    const { logs: depNFT1Logs } = await bundle.depositERC721Asset(
      bundle1,
      NFT1.address,
      acc1NFT1Id,
      {
        from: accounts[1]
      }
    );

    var acc1NFT1Id0InBundle = await bundle.erc721Assets(
      bundle1,
      NFT1.address,
      acc1NFT1Id
    );

    assert.equal(acc1NFT1Id0InBundle, true);
    assert.equal(depNFT1Logs.length, 3);
    assert.equal(depNFT1Logs[2].event, "DepositERC721");
    assert.equal(depNFT1Logs[2].args.bundleId.toNumber(), bundle1);
    assert.equal(depNFT1Logs[2].args.token, NFT1.address);
    assert.equal(depNFT1Logs[2].args.id.toNumber(), acc1NFT1Id.toNumber());
  });

  it(`lock bundle`, async () => {
    const { logs: lockLogs } = await bundle.lock(bundle1);
    var lockStatus = await bundle.locked(bundle1);
    assert.equal(lockStatus, true);
    assert.equal(lockLogs[0].event, "Lock");
    assert.equal(lockLogs[0].args.bundleId.toNumber(), bundle1);
  });

  it(`unlock bundle`, async () => {
    const { logs: unlockLogs } = await bundle.unlock(bundle1);
    var lockStatus = await bundle.locked(bundle1);
    assert.equal(lockStatus, false);
    assert.equal(unlockLogs[0].event, "Unlock");
    assert.equal(unlockLogs[0].args.bundleId.toNumber(), bundle1);
  });
});
