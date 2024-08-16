// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract TwitterContract{
    
    struct  Tweet{
        uint ID;
        address author;
        string content;
        uint timestamp;
    }

    struct Message{
        uint ID;
        string content;
        address sender;
        address receiver;
        uint timestamp;
    }

    mapping(uint=>Tweet) public tweets;
    mapping(address=>uint[]) public tweetsOf;
    mapping(address=>Message[]) public conversation;
    mapping(address=>mapping(address=>bool)) public operators;
    mapping(address=>address[]) public following;

    uint nextId;
    uint nextMessageId;

    function _tweet(address _from, string memory _content) public {
        require(operators[msg.sender],"Not Authorized");
        tweets[nextId] = Tweet(nextId,_from,_content,block.timestamp);
        tweetsOf[_from].push(nextId);
        nextId = nextId+1;
    }

    function _sendMessage(address _from, address _to, string memory _content) public {
        conversation[_from].push(Message(nextMessageId,_content,_from,_to,block.timestamp));
        nextMessageId++;
   }

    function tweet(string memory _content) public {
        _tweet(msg.sender,_content);
    }

    function tweet(address _from, string memory _content) public {
        _tweet(_from,_content);
    }

    function sendMessage(address _to, string memory _content) public {
        _sendMessage(msg.sender, _to, _content);
    }

    function sendMessage(address _from, address _to, string memory _content) public {
       _sendMessage(_from,_to,_content);
    }

    function follow(address _followed) public {
       following[msg.sender].push(_followed);
    }

    function allow(address _operator) public {
       operators[msg.sender][_operator]=true;
    }

    function disallow(address _operator) public {
        operators[msg.sender][_operator]=false;
    }

    function getLatestTweets(uint count) public view returns(Tweet[] memory) {
        require(count>0 && count<=nextId,"Count is not proper");
        Tweet[] memory _tweets = new Tweet[](count);

        uint j;

        for(uint i=nextId-count; i<nextId; i++){
            Tweet storage _structure = tweets[i];
            _tweets[j]=Tweet(
              _structure.ID, 
              _structure.author, 
              _structure.content, 
              _structure.timestamp);
              j=j+1;
        }
        return _tweets;
    }

    function getLatestTweetOf(address user, uint count) public view returns(Tweet[] memory){
        Tweet[] memory _tweets = new Tweet[] (count);
        uint[] memory ids = tweetsOf[user];
        
        require(count>0 && count<ids.length,"Count is not defined");

        uint j;

        for(uint i=ids.length-count; i<ids.length; i++){
            Tweet storage _structure = tweets[ids[i]];
              _tweets[j]=Tweet(
              _structure.ID, 
              _structure.author, 
              _structure.content, 
              _structure.timestamp);
            j=j+1;
        }
        return _tweets;
    }

}
