pragma solidity ^0.4.19;

/**
 * Registry for providers.
 */
contract ProviderRegistry {
    /**
     * Event thrown whenever a provider is added or changed.
     */
    event ProviderInfoUpdate(
        uint256 id,
        string name,
        string metadata,
        address owner,
        uint256 version
    );

    /**
     * Represents a provider of some sort of service.
     */
    struct ProviderInfo {
        uint256 id;
        string name;
        string metadata;
        address owner;
        uint256 version;
    }
    mapping (uint256 => ProviderInfo) providers;

    uint256 nextProviderId = 0;

    function registerProvider(
        string name,
        string metadata,
        address owner
    ) external
    {
        uint256 providerId = nextProviderId++;
        providers[providerId] = ProviderInfo({
            id: providerId,
            name: name,
            metadata: metadata,
            owner: owner,
            version: 1
        });
        ProviderInfoUpdate({
            id: providerId,
            name: name,
            metadata: metadata,
            owner: owner,
            version: 1
        });
    }

    function upgradeProvider(
        string metadata,
        address owner
    ) external returns (bool)
    {
        uint256 providerId = nextProviderId++;
        ProviderInfo storage info = providers[providerId];
        // Check if the provider existed
        if (info.version == 1) {
            return false;
        }

        // Check if the provider is authorized to be upgraded by sender
        if (msg.sender != info.owner) {
            return false;
        }
        uint256 nextVersion = info.version + 1;

        // Check if we're allowed.
        providers[providerId] = ProviderInfo({
            id: providerId,
            name: info.name,
            metadata: metadata,
            owner: owner,
            version: nextVersion
        });
        ProviderInfoUpdate({
            id: providerId,
            name: info.name,
            metadata: metadata,
            owner: owner,
            version: nextVersion
        });
        return true;
    }

    /**
     * Adjacency matrix, where address is the constituent (one who trusts),
     * uint256 is the trustee (provider id of one who is trusted), and the last
     * uint256 is the version of the provider trusted.
     * A zero version represents lack of trust.
     */
    mapping (address => mapping(uint256 => uint256)) public trustMatrix;

    /**
     * Writes that msg.sender trusts a provider.
     */
    function trustProvider(uint256 providerId) external {
        trustMatrix[msg.sender][providerId] = providers[providerId].version;
    }

    /**
     * Untrusts a provider.
     */
    function untrustProvider(uint256 providerId) external {
        trustMatrix[msg.sender][providerId] = 0;
    }

    function providerOwner(uint256 providerId) view external returns (address) {
        return providers[providerId].owner;
    }

}