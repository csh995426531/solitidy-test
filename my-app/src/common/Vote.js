import React from 'react'
import ReactDOM from 'react-dom';
import Web3 from 'web3'

class Proposal extends React.Component {

  render(){
    return (
      this.props.data.map((item, index)=>{
        return <li key={index} >提案名：{item.name}，当前票数：{item.voteCount} <input type='radio' name="proposal" value={index} ></input></li>
      })
    )
  }
}

class Vote extends React.Component {
    
    //获取提案结果
    getResult(){
        contract.methods.winnerName().call().then(function(result){
        console.log(result)
        })
    }

    //获取提案列表
    getList(){

        let proposalsArray = new Array(0);
        contract.methods.proposalsArray().call({form: myAddress}).then(function(result){
            for (var i=0; i< result.length; i++) {
                proposalsArray.push({
                name: web3.utils.hexToString(result[i].name),
                voteCount: result[i].voteCount
                })
            }
            
            ReactDOM.render(
                <Proposal data={proposalsArray}/>,
                document.getElementById('proposalList')
            )
        })
    }

    //提交投票
    submitVote(){
        let voteIndex = 0
        document.getElementsByName('proposal').forEach(function(item){
          if (item.checked) {
            voteIndex = item.value
          }
        })

        contract.methods.vote(voteIndex).send({from: myAddress}).then(function(result){
          console.log("result", result)
        }).catch(function(error){
          console.log("error:",error)
        })
    }

	//发放投票权
	giveRightToAddress(){
		let giveRightToAddress = document.getElementById('giveRightToAddress').value
        console.log(giveRightToAddress)

		//获取主席地址
		contract.methods.chairperson().call({from: giveRightToAddress}).then(function(result){
			//发放投票权
			contract.methods.giveRightToVote(giveRightToAddress).send({from: result}).then(function(result){
				console.log("result", result)
			}).catch(function(error){
				console.log("error:",error)
			})
		}).catch(function(error){
			console.log("error:",error)
		})
	}

	//委托投票
	delegate(){

		let delegateAddress = document.getElementById('delegateAddress').value
        console.log(delegateAddress)
		contract.methods.delegate(delegateAddress).send({from: myAddress}).then(function(result){
			console.log("result", result)
		}).catch(function(error){
			console.log("error", error)
		})
	}

	login(){
		myAddress = document.getElementById('myAddress').value
		document.getElementById('loginStatus').style.color = "green"
	}

	logout(){
		myAddress = ""
		document.getElementById('myAddress').value = ""
		document.getElementById('loginStatus').style.color = "#ff0000"
	}


    render() {
        return (
            <div className="vote">
				登陆钱包地址：<input type='text' name="myAddress" id="myAddress"></input><button onClick={this.login}>登陆</button><button onClick={this.logout}>退出</button>
				<span className="icon iconfont" id='loginStatus' ref={ this.manage }>&#xe621;</span>
				<br></br>
				<h4>委托投票</h4>
				目标地址：<input type='text' name="delegateAddress" id="delegateAddress"></input><button onClick={this.delegate}>委托</button>
				<h4>提案列表</h4>
                <button onClick={this.getResult}>获取结果</button>
                <button onClick={this.getList}>获取提案列表</button>
                <ul id='proposalList'></ul>
                <button onClick={this.submitVote}>投票</button><br></br>
				<h3>超管身份发放投票权</h3>
				地址：<input type='text' name="giveRightToAddress" id="giveRightToAddress"></input><button onClick={this.giveRightToAddress}>发放</button>
				
            </div>
        );
    }
}

let myAddress = ""

const contractAddress = "0x6ec986D15ce5b60F2C9c8Eb5a94dA7FD7E80a83B"

const contractAbi = [
	{
		"inputs": [
			{
				"internalType": "string[]",
				"name": "proposalNames",
				"type": "string[]"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "chairperson",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			}
		],
		"name": "delegate",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "voter",
				"type": "address"
			}
		],
		"name": "giveRightToVote",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "proposals",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "name",
				"type": "bytes32"
			},
			{
				"internalType": "uint256",
				"name": "voteCount",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "proposalsArray",
		"outputs": [
			{
				"components": [
					{
						"internalType": "bytes32",
						"name": "name",
						"type": "bytes32"
					},
					{
						"internalType": "uint256",
						"name": "voteCount",
						"type": "uint256"
					}
				],
				"internalType": "struct Ballot.Proposal[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposal",
				"type": "uint256"
			}
		],
		"name": "vote",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "voters",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "weight",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "voted",
				"type": "bool"
			},
			{
				"internalType": "address",
				"name": "delegate",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "vote",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "winnerName",
		"outputs": [
			{
				"internalType": "string",
				"name": "winnerName_",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "winningProposal",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "winningProposal_",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]

const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:7545'));
const contract = new web3.eth.Contract(contractAbi, contractAddress)
web3.eth.defaultAccount = web3.eth.accounts[0]

export default Vote;