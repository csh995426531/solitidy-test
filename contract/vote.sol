// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.11;

/// @title 委托投票
contract Ballot {

    // 选民
    struct Voter {
        uint weight; //权重
        bool voted; //是否已投票
        address delegate; //委托人
        uint vote; //提案索引
    }

    //提案
    struct Proposal {
        bytes32 name; //名称
        uint voteCount; //得票数
    }

    //主席
    address public chairperson; 

    //选民map
    mapping(address => Voter) public voters;

    //提案数组
    Proposal[] public proposals;

    //构造函数
    constructor(string[] memory proposalNames) {
        //设置主席
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        //初始化提案
        for (uint i=0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: stringToBytes32(proposalNames[i]),
                voteCount: 0
            }));
        }
    }

    //授权投票
    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(
            voters[voter].weight == 0,
            "The voter already give weight."
        );
        voters[voter].weight = 1;
    }

    //委托投票权
    function delegate(address to) public {
        require(
            msg.sender != to,
            "Self-delegation is disallowed."
        );

        Voter storage sender = voters[msg.sender];
        require(
            !sender.voted,
            "You already voted."
        );

        while (voters[to].delegate != address(0)) {
          to =  voters[to].delegate;

          //不允许闭环委托
          require(to != msg.sender, "Found loop in delegation."); 
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
    
        if (delegate_.voted) {
            //若被委托者已投过票,直接增加得票数
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            //若被委托者没有投过票，增加被委托者的权重
            delegate_.weight += sender.weight;
        }
    }

    //把票投给提案
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(
            !sender.voted,
            "You already voted."
        );
        require(
            sender.weight > 0,
            "You not have voted right."
        );
        sender.voted = true;
        sender.vote = proposal;

        //提案增加得票数
        proposals[proposal].voteCount += sender.weight;
    }

    // @dev 结合之前的所有投票，计算出最终的胜出提案
    function winningProposal() public view returns(uint winningProposal_) {
         uint winningCount = 0;
         for (uint p=0; p < proposals.length; p++) {
             if (proposals[p].voteCount > winningCount) {
                 winningProposal_ = p;
             }
         }
    }

     //返回获胜的提案名称
     function winnerName() public view returns (string memory winnerName_) {
        bytes32 tempName = proposals[winningProposal()].name;
        winnerName_ = bytes32ToString(tempName);
     }

     //获取提案信息
     function proposalsArray() public view returns (Proposal[] memory) {
        return proposals;
     }

     function bytes32ToString(bytes32 _bytes32) private pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

}