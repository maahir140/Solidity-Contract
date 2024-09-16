// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract NewsPaperPortal{
   
   struct Article{
    uint id;
    string title;
    string contant;
    address author;
    uint timestamp;
    bool isPublished;
   }

    uint public articleCount =0;
    address public owner;

    mapping(uint => Article) public articles;
    mapping(address => bool) public editors;
    mapping(address => bool) public writers;

    modifier onlyOwner(){  
        require(msg.sender == owner, "Not the contract Owner");
        _;
    }

    modifier onlyWriter(){
        require(writers[msg.sender], "Not a Writer");
        _;
    }
// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    modifier onlyEditor(){
        require(editors[msg.sender], "Not a Editors");
        _;
    }

    constructor(){
        owner = msg.sender;
        editors[owner] = true;
    }

    function addEditors(address _editorAddress) public onlyOwner{
        editors[_editorAddress] = true;
    }

    function addWriters(address _writerAddress) public onlyOwner{
        writers[_writerAddress] = true;
    }

    function publishArticle(string memory _title, string memory _content) public onlyOwner{
        articleCount++;
        articles[articleCount] = Article(articleCount, _title, _content, msg.sender, block.timestamp, true);
    }

    function editArticle(uint _id, string memory _newcontent) public onlyEditor{
        require(articles[_id].isPublished, "Article not published");
        articles[_id].contant = _newcontent;
        articles[_id].timestamp = block.timestamp;
    }

    function archiveArticle(uint _id) public onlyOwner{
        require(articles[_id].isPublished, "Article not published");
        articles[_id].isPublished = false;
    }

}
