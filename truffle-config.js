const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require('web3');

require('dotenv').config();

/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation, and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * https://trufflesuite.com/docs/truffle/reference/configuration
 *
 * Hands-off deployment with Infura
 * --------------------------------
 *
 * Do you have a complex application that requires lots of transactions to deploy?
 * Use this approach to make deployment a breeze 🏖️:
 *
 * Infura deployment needs a wallet provider (like @truffle/hdwallet-provider)
 * to sign transactions before they're sent to a remote public node.
 * Infura accounts are available for free at 🔍: https://infura.io/register
 *
 * You'll need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. You can store your secrets 🤐 in a .env file.
 * In your project root, run `$ npm install dotenv`.
 * Create .env (which should be .gitignored) and declare your MNEMONIC
 * and Infura PROJECT_ID variables inside.
 * For example, your .env file will have the following structure:
 *
 * MNEMONIC = <Your 12 phrase mnemonic>
 * PROJECT_ID = <Your Infura project id>
 *
 * Deployment with Truffle Dashboard (Recommended for best security practice)
 * --------------------------------------------------------------------------
 *
 * Are you concerned about security and minimizing rekt status 🤔?
 * Use this method for best security:
 *
 * Truffle Dashboard lets you review transactions in detail, and leverages
 * MetaMask for signing, so there's no need to copy-paste your mnemonic.
 * More details can be found at 🔎:
 *
 * https://trufflesuite.com/docs/truffle/getting-started/using-the-truffle-dashboard/
 */

// require('dotenv').config();
// const { MNEMONIC, PROJECT_ID } = process.env;

// const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a managed Ganache instance for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

    networks: {
    
    kovan: {
      provider: function() {
        return new HDWalletProvider(
          process.env.MNENOMIC,
          "wss://kovan.infura.io/ws/v3/" + process.env.INFURA_API_KEY
        )
      },
      network_id: 42,
      networkCheckTimeout: 1000000,
      timeoutBlocks: 200,
      gasPrice: 1e9 // 1 gewi
    },

    //for eth
    /*development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
      gas: 8000000,
    }*/

    development: {
      provider: () => new Web3.providers.HttpProvider('http://127.0.0.1:9545/ext/bc/C/rpc'),
      network_id: "*",
      gas: 8000000,
      gasPrice: 25000000000 // 25 nAVAX for now
    },
  
    matic: {
      provider: function() {
        return new HDWalletProvider({
            privateKeys: [process.env.MAINNET_RETHINK_PRIVATE_KEY], 
            providerOrUrl: "https://polygon-bor.publicnode.com",
            //providerOrUrl: "https://polygon-testnet.blastapi.io/4d2d0ede-b1cd-43fa-a3b0-db1fefae4322",
            retryTimeout: 4000,
            pollingInterval: 8000,
        })
      },
      deploymentPollingInterval: 16000,
      network_id: 137,
      networkCheckTimeout: 1000000,
      timeoutBlocks: 200,
      gasPrice: 401e8 // 60.1 gewi
    },

    mumbai: {
      
      provider: function() {
        return new HDWalletProvider({
            privateKeys: [process.env.MUMBAI_PRIVATE_KEY], 
            providerOrUrl: "https://rpc.ankr.com/polygon_mumbai",
            //providerOrUrl: "https://polygon-testnet.blastapi.io/4d2d0ede-b1cd-43fa-a3b0-db1fefae4322",
            pollingInterval: 8000,
        })
        //return new HDWalletProvider(process.env.TESTNET_PRIVATE_KEY, "https://matic-mumbai.chainstacklabs.com/")
      },
      deploymentPollingInterval: 16000,
      gas: 8000000,
      network_id: 80001,
      networkCheckTimeout: 1000000,
      timeoutBlocks: 200,
      from: "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6",
      gasPrice: 31e8, // 301e8, //30.1 gewi
      disableConfirmationListener: true
    },
    fuji: {
      provider: function() {
        return new HDWalletProvider({
            privateKeys: [process.env.MUMBAI_PRIVATE_KEY], 
            providerOrUrl: "https://api.avax-test.network/ext/bc/C/rpc",
            pollingInterval: 1000,
        })
        //return new HDWalletProvider(process.env.TESTNET_PRIVATE_KEY, "https://matic-mumbai.chainstacklabs.com/")
      },
      deploymentPollingInterval: 2000,
      network_id: "*",
      gas: 8000000,
      gasPrice: 25000000000,
      //gas: 8000000,
      //gasLimit: 80000000,
      //network_id: 43113,
      networkCheckTimeout: 1000000,
      timeoutBlocks: 200,
      from: "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6",
      //gasPrice: 25, // 301e8, //30.1 gewi
      disableConfirmationListener: true
    },
    arbgoerli: {
      provider: function() {
        return new HDWalletProvider({
            privateKeys: [process.env.MUMBAI_PRIVATE_KEY], 
            providerOrUrl: "https://goerli-rollup.arbitrum.io/rpc",
            pollingInterval: 16000,
        })
        //return new HDWalletProvider(process.env.TESTNET_PRIVATE_KEY, "https://matic-mumbai.chainstacklabs.com/")
      },
      deploymentPollingInterval: 32000,
      network_id: 421613,
      //gasLimit: 80000000,
      //network_id: 43113,
      networkCheckTimeout: 1000000,
      timeoutBlocks: 200,
      from: "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6",
      //gas: 5377410000000,
      //gasPrice: 160276, // 301e8, //30.1 gewi
      disableConfirmationListener: true
    },
    goerli: {
      provider: function() {
        return new HDWalletProvider({
            privateKeys: [process.env.MUMBAI_PRIVATE_KEY], 
            providerOrUrl: "https://goerli.blockpi.network/v1/rpc/public",
            retryTimeout: 8000,
            pollingInterval: 16000,
        })
        //return new HDWalletProvider(process.env.TESTNET_PRIVATE_KEY, "https://matic-mumbai.chainstacklabs.com/")
      },
      deploymentPollingInterval:16000,
      network_id: 5,
      gas: 8000000,
      retryTimeout: 8000,
      gasPrice: 10e8,
      //gas: 8000000,
      //gasLimit: 80000000,
      //network_id: 43113,
      networkCheckTimeout: 1000000,
      timeoutBlocks: 200,
      from: "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6",
      //gasPrice: 25, // 301e8, //30.1 gewi
      disableConfirmationListener: true
    },
    fcanto: {
      provider: function() {
        return new HDWalletProvider({
            privateKeys: [process.env.MUMBAI_PRIVATE_KEY], 
            providerOrUrl: "https://canto-testnet.plexnode.wtf",
            pollingInterval: 10000,
        })
        //return new HDWalletProvider(process.env.TESTNET_PRIVATE_KEY, "https://matic-mumbai.chainstacklabs.com/")
      },
      deploymentPollingInterval: 20000,
      network_id: 7701,
      //gas: 8000000,
      //gasPrice: 31e8,
      //gas: 8000000,
      //gasLimit: 80000000,
      //network_id: 43113,
      networkCheckTimeout: 1000000,
      timeoutBlocks: 200,
      from: "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6",
      //gasPrice: 25, // 301e8, //30.1 gewi
      disableConfirmationListener: true
    }
  },


  // Set default mocha options here, use special reporters, etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.17", // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
            enabled: true,
            runs: 200
        },
      //  evmVersion: "byzantium"
      }
    }
  }

  // Truffle DB is currently disabled by default; to enable it, change enabled:
  // false to enabled: true. The default storage location can also be
  // overridden by specifying the adapter settings, as shown in the commented code below.
  //
  // NOTE: It is not possible to migrate your contracts to truffle DB and you should
  // make a backup of your artifacts to a safe location before enabling this feature.
  //
  // After you backed up your artifacts you can utilize db by running migrate as follows:
  // $ truffle migrate --reset --compile-all
  //
  // db: {
  //   enabled: false,
  //   host: "127.0.0.1",
  //   adapter: {
  //     name: "indexeddb",
  //     settings: {
  //       directory: ".db"
  //     }
  //   }
  // }
};
