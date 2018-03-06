var HDWalletProvider = require("truffle-hdwallet-provider");
var infura_apikey = "jdk52xCSA6hUrdsL349g" ; // Either use this key or get yours at https://infura.io/signup. It's free.
var mnemonic = "";

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7546,
      gas: 6800000,
      network_id: "5778"
    },
    ropsten:  {
      provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/" + infura_apikey),
      network_id: 3,
      gas: 4500000
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};
