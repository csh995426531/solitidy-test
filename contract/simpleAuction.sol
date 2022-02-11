// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.11;

contract SimpleAuction {
    //拍卖人
    address payable public beneficiary;
    //结束时间
    uint public auctionEndTime;

    //拍卖状态
    address public highestBidder;
    uint public highestBid;

    bool ended;

    //可取回的出价
    mapping(address => uint) pendingReturns;


    //事件定义
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);


    //错误定义

    /// The auction has already ended.
    error AuctionAlreadyEnded();
    /// There is already a higher or equal bid.
    error BidNotHighEnough(uint highestBid);
    /// The auction has not ended yet.
    error AuctionNotYetEnded();
    /// The function auctionEnd has already been called.
    error AuctionEndAlreadyCalled();

    // 以下是所谓的 natspec 注释，可以通过三个斜杠来识别。
    // 当用户被要求确认交易时将显示。

    /// 以受益者地址 `_beneficiary` 的名义，
    /// 创建一个简单的拍卖，拍卖时间为 `_biddingTime` 秒。
    constructor (
        uint _biddingTime,
        address payable _beneficiary
    ){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    /// 对拍卖进行出价，具体的出价随交易一起发送
    /// 如果没有在拍卖中胜出，则返还出价
    function bid() external payable {
        // 参数不是必要的，因为所有的信息已经包含在了交易中。
        // 对于能接受以太币的函数，payable关键字是必须的

        // 拍卖已结束
        if (block.timestamp > auctionEndTime)
            revert AuctionAlreadyEnded();

        // 出价不够
        if (msg.value < highestBid)
            revert BidNotHighEnough(highestBid);

        if (highestBid > 0) {
            // 返还出价时，简单地直接调用 highestBidder.send(highestBid) 函数，
            // 是有安全风险的，因为它有可能执行一个非信任合约。
            // 更为安全的做法是让接收方自己提取金钱。
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// 取回出价
    function withdraw() external returns(bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // 这里很重要，首先要设零值
            // 因为，作为接受调用的一部分，
            // 接受者可以在`send`返回之前，重新调用该函数
            pendingReturns[msg.sender] = 0;
            if (!payable(msg.sender).send(amount)) {
                // 这里不需要抛出异常，只需重置金额
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// 结束拍卖，并把最高的出价发送给受益人
    function auctionEnd() external {

        // 拍卖时间未到
        if (block.timestamp < auctionEndTime)
            revert AuctionNotYetEnded();
        // 拍卖已结束过
        if (ended)
            revert AuctionEndAlreadyCalled();
        
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }

}