//Kovan test material
require('dotenv').config();
var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = process.env.MNEMONIC;
var infura_key = process.env.INFURA_KEY;

module.exports = {
  networks: {

    // kovan: {
    //   provider: function() {
    //     return new HDWalletProvider(mnemonic, "https://kovan.infura.io/3966a6050a6d4e9da3f777d2586bafba")
    //   },
    //   network_id: 3
    // }

    rinkeby: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/"+infura_key)
      },
      network_id: 2,
      gas: 6721975
    }

    // development: {
    //   host: "localhost",
    //   port: 8545,
    //   network_id: "*", // Match any network id // testrpc
    //   // port: 7545,
    //   // network_id: "5777", //ganache
    //   gas: 6721975
    // }

  }
};
