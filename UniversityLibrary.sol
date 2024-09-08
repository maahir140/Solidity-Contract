// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Library{

    address public Admin;

    struct Book{
        string title;
        string author;
        uint noOfCopies;
        uint avilable;
    }

    struct borrowRecord{
        address studentAddress;
        uint borrowTime;
        bool isReturn;
    }

    struct Student{
        string studentName;
        uint borrowedBook;
        bool isRegistered;
    }

    uint constant max_borrow_book = 3;
    uint constant durationOfBorrowBook = 14;

    mapping(uint => Book) public books;
    mapping(uint => borrowRecord[]) public borrowBookHistroy;
    mapping(address => Student) public students;

    uint public BookCounter;

    modifier OnlyAdmin(){
        require(msg.sender == Admin, "Not Admin");
        _;
    }

    modifier OnlyRegisteredStudent(){
        require(students[msg.sender].isRegistered,"Not Registered student");
        _;
    }

    event AddBook(uint bookId, string title, string author, uint copies);
    event RemovedBook(uint bookId);
    event BorrowBook(uint bookId, address studentAddress);
    event ReturnBook(uint bookId, address studentAddress);
    event RegistraionStudent(address studentAddress, string studentName);

    constructor(){
        Admin = msg.sender;
    }

    function registerStudent(address _studentAddress, string memory _name) public OnlyAdmin{
        require(!students[msg.sender].isRegistered,"Already registered student");
        students[_studentAddress] = Student(_name, 0, true);
        emit RegistraionStudent(_studentAddress, _name);
    }

    function addBook(string memory _title, string memory _author, uint _copies) public OnlyAdmin{
        require(_copies > 0, "Must add atleast one book");
        books[BookCounter] = Book(_title, _author, _copies, _copies);
        emit AddBook( BookCounter, _title, _author, _copies);
        BookCounter++;
    }

    function trackBookId(string memory _title, string memory _author) public view returns(uint bookId, bool found){
        for (uint i = 0; i < BookCounter; i++) {
            if (keccak256(abi.encodePacked(books[i].title)) == keccak256(abi.encodePacked(_title)) &&
                keccak256(abi.encodePacked(books[i].author)) == keccak256(abi.encodePacked(_author))) {
                return (i, true);  
            }
        }
        return (0, false);
    }

    function removeBook(uint bookId) public OnlyAdmin{
        require(bookId < BookCounter, "Book Id does't exist");
        delete books[bookId];
        emit RemovedBook(bookId);
        BookCounter--;
    }

    function borrowBook(uint bookId) public OnlyRegisteredStudent{
        require(bookId < BookCounter,"This book id doesn't exist");
        require(books[bookId].avilable > 0, "Not avilable");
        require(students[msg.sender].borrowedBook < max_borrow_book, "Your book borrow limits are full!!");

        books[bookId].avilable--;
        students[msg.sender].borrowedBook++;
        borrowBookHistroy[bookId].push(borrowRecord(msg.sender, block.timestamp, true));
        emit BorrowBook(bookId, msg.sender);
    }

    function returnBook(uint bookId) public OnlyRegisteredStudent{
        require(bookId < BookCounter, "This book id doesn't exist");

        borrowRecord[] storage records = borrowBookHistroy[bookId];
        bool found = false;
        for(uint i=0; i<records.length; i++){
            if(records[i].studentAddress == msg.sender && !records[i].isReturn){
                records[i].isReturn = true;
                found = true;
                if(block.timestamp > records[i].borrowTime + durationOfBorrowBook){
                }
                books[bookId].avilable++;
                students[msg.sender].borrowedBook--;
                emit ReturnBook(bookId, msg.sender);
                break;
            }
        } 
    }

    function getBorrowedbookCounter(address studentAddress) public view returns(uint) {
        return students[studentAddress].borrowedBook;
    } 

    function checkBookAvilablity(uint bookId) public view returns(uint){
        require(bookId < BookCounter, "This Book id doesn't exist");
        return books[bookId].avilable;
    }
}
