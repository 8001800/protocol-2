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
      from: "0x16779b7B0736080843adFAb1ea34C624fC70E0Ff",
      network_id: 4,
      gas: 4000000
    }

  },

  optimizer: {
    enabled: true,
    runs: 500
  },

};
