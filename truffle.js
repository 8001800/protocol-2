module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },

    rinkeby: {
      host: "127.0.0.1",
      port: 8545,
      from: process.env.ETH_ACCOUNT,
      network_id: 4,
      gas: 4000000
    }
  },

  optimizer: {
    enabled: true,
    runs: 500
  }
};
