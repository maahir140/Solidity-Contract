// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Dictionary{

    struct Word{
        string wordDefinition;
        bool isPrivate;
        address owner;
    }

    mapping(string => Word) private dictionary;
    string[] private wordList;

    event WordAdded(string word, string wordDefinition, bool isPrivate);
    event WordUpdated(string word, string wordNewDefiniton);
    event WordDelet(string word);

    modifier onlyOwner(string memory _word){  
        require(msg.sender == dictionary[_word].owner, "Not the word Owner");
        _;
    }

    function addWord(string memory _word, string memory _wordDefinition, bool _isprivate) public {
        require(bytes(dictionary[_word].wordDefinition).length == 0, "Word Already Exist");
        dictionary[_word] = Word({
            wordDefinition: _wordDefinition,
            isPrivate:  _isprivate,
            owner: msg.sender
        });
        wordList.push(_word);
        emit WordAdded(_word, _wordDefinition, _isprivate);   
    }

    function getWordDefinition(string memory _word) public view returns(string memory){
        require(bytes(dictionary[_word].wordDefinition).length != 0, "Word Not Exist");
        if (dictionary[_word].isPrivate){
            require(msg.sender == dictionary[_word].owner,"This Word is private");
        }
        return dictionary[_word].wordDefinition;
    }

    function updateDefinition(string memory _word, string memory _newdefinition) public onlyOwner(_word){
        require(bytes(dictionary[_word].wordDefinition).length == 0, "Word Already Exist");
        dictionary[_word].wordDefinition = _newdefinition;
        emit WordUpdated(_word, _newdefinition);
    }

    function deletWord(string memory _word) public {
        require(bytes(dictionary[_word].wordDefinition).length != 0, "Word not Exist");
        delete dictionary[_word];
        removeWordFromList(_word);
        emit WordDelet(_word);
    }

    function searchWord(string memory _prefix) public view returns(string[] memory){
        uint count = 0;
        for(uint i=0; i<=wordList.length; i++){
            if(startWith(wordList[i], _prefix)){
                count++;
            }
        }
        string[] memory result = new string[](count);
        uint index=0;
        for(uint i=0; i<=wordList.length; i++){
            if(startWith(wordList[index], _prefix)){
                result[index] = wordList[i];
                index++;
            }
        }
        return result;
    }

    function startWith(string memory _word, string memory _prefix) internal pure returns(bool){
        bytes memory wordBytes = bytes(_word);
        bytes memory prefixBytes = bytes(_prefix);
        if(prefixBytes.length > wordBytes.length) return false;
        for(uint i=0; i < prefixBytes.length; i++){
            if(wordBytes[i] != prefixBytes[i]) return false;
        }
        return true;
    }

    function getWordCount() public view returns(uint){
        return wordList.length;
    }

    function removeWordFromList(string memory _word) internal{
        for(uint i=0; i<=wordList.length; i++){
            if (keccak256(abi.encodePacked(wordList[i])) == keccak256(abi.encodePacked(_word))){
                wordList[i] = wordList[wordList.length - 1];
                wordList.pop();
                break;
            }
        }
    }
}
