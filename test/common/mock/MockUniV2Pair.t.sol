// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

contract MockUniV2Pair {
	//NOTE: for nav liquid
	address _t1;
	address _t0;

	constructor(address t0, address t1){
		_t0 = t0;
		_t1 = t1;		
	}
	

	/*


		console.log('Deploy fake Pangolin Factory');
	  // We need an address arg to the contract
	  let pangolinArg = '';
	  for (let i = 0; i < 32; i++) { pangolinArg += '00';}
	  const pangolinFactoryAddress = (await web3.eth.sendTransaction({from: accounts[0], gas: 8000000, data: PangolinFactoryBytecode + pangolinArg})).contractAddress;

	  console.log('Deploy fake wAVAX');
	  const wAVAXAddress = (await web3.eth.sendTransaction({from: accounts[0], gas: 8000000, data: WAVAXBytecode})).contractAddress;

	  console.log('Deploy fake Pangolin Router');
	  console.log(pangolinFactoryAddress.substr(2));
	  console.log(wAVAXAddress.substr(2));
	  console.log(web3.eth.abi.encodeParameters(['address', 'address'],[pangolinFactoryAddress, wAVAXAddress]).slice(2));
	  const PangolinRouterAddress = (await web3.eth.sendTransaction({
	    from: accounts[0],
	    gas: 8000000,
	    data: PangolinRouter02Bytecode + web3.eth.abi.encodeParameters(['address', 'address'],[pangolinFactoryAddress, wAVAXAddress]).slice(2)
	  })).contractAddress;


	*/
	function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = 1311499952458300268383695;
        _reserve1 = 246623759970843809984;
        _blockTimestampLast = 171774987;
    }

	function price0CumulativeLast() external view returns (uint256) {
		return 245649376887916256817765255137784685103;
	}

	function price1CumulativeLast() external view returns (uint256) {
		return 3281446373720487346942499382764644958354054707;
	}

	function token0() external view returns (address) {
		return _t0;
	}

	function token1() external view returns (address) {
		return _t1;
	}
}