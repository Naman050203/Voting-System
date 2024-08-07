const Web3 = require('web3');
const fs = require('fs');
const path = require('path');

const web3 = new Web3('https://api.diamantechain.com'); // Replace with your Diamante Chain node URL

const account = web3.eth.accounts.privateKeyToAccount('YOUR_PRIVATE_KEY');
web3.eth.accounts.wallet.add(account);

const contractPath = path.resolve(__dirname, '../contracts', 'Voting.sol');
const source = fs.readFileSync(contractPath, 'utf8');
// Compile the Solidity contract (assuming using solc-js)
const solc = require('solc');
const input = {
    language: 'Solidity',
    sources: {
        'Voting.sol': {
            content: source,
        },
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['abi', 'evm.bytecode'],
            },
        },
    },
};
const output = JSON.parse(solc.compile(JSON.stringify(input)));
const contract = output.contracts['Voting.sol'].Voting;
const contractABI = contract.abi;
const contractBytecode = contract.evm.bytecode.object;

const deploy = async () => {
    const contractInstance = new web3.eth.Contract(contractABI);
    const deployTx = contractInstance.deploy({
        data: '0x' + contractBytecode,
        arguments: ['Election Name']
    });

    const gas = await deployTx.estimateGas();
    const deployReceipt = await deployTx.send({
        from: account.address,
        gas: gas
    });

    console.log('Contract deployed at address:', deployReceipt.options.address);
};

deploy();
