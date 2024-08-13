// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Vote {

    struct Voter {
        string name;
        uint age;
        uint voterId;
        Gender gender;
        uint voteCandidateId;
        address voterAddress;
    }

    struct Candidate {
        string name;
        string party;
        uint age;
        Gender gender;
        uint candidateId;
        address candidateAddress;
        uint votes;
    }

    address electionCommission;

    address public winner;
    uint nextVoterId = 1;
    uint nextCandidateId = 1;
    uint startTime;
    uint endTime;
    bool stopVoting;


    mapping(uint => Voter) voterDetails;
    mapping(uint => Candidate) candidateDetails;

    enum VotingStatus {NotStarted, InProgress, Ended}
    enum Gender {NotSpecified, Male, Female, Other}

    constructor() {
        electionCommission=msg.sender; //msg.sender is a global variable
    }

    modifier isVotingOver() {
        require(block.timestamp<=endTime && stopVoting == false,"Voting is over");
        _;
    }

    modifier onlyCommissioner() {
        require(msg.sender == electionCommission, "Not Authuorized");
        _;
    }

    modifier isValidAge(uint _age){
        require(_age>=18,"not eligible for voting");
        _;
    }

    function registerCandidate(
        string calldata _name,
        string calldata _party,
        uint _age,
        Gender _gender
    ) external isValidAge(_age){
      
       require(isCandidateNotRegistered(msg.sender),"You are already registered"); 
       require(nextCandidateId<5,"candiate Registration Full");
       require(msg.sender!=electionCommission,"Election Commission not allowed to register"); 
       candidateDetails[nextCandidateId] = Candidate({
        name:_name,
        party:_party, 
        age:_age, 
        gender:_gender, 
        candidateId:nextCandidateId,
        candidateAddress:msg.sender, 
        votes:0});
        nextCandidateId++;
    }

    function isCandidateNotRegistered(address _person) internal view returns (bool) {
           for(uint i=1;i<nextCandidateId;i++){
              if(candidateDetails[i].candidateAddress==_person){
                return false;
              }
           }
           return true;
    }

    function getCandidateList() public view returns (Candidate[] memory) {
           Candidate[] memory candidateList = new Candidate[](nextCandidateId - 1);
            for (uint i = 0; i < candidateList.length; i++){
                candidateList[i] = candidateDetails[i + 1];
            }
            return candidateList;
    }

    function isVoterNotRegistered(address _person) internal view returns (bool) {
          for(uint i=1;i<nextCandidateId;i++){
              if(voterDetails[i].voterAddress==_person){
                return false;}
          }
          return true;
    }

    function registerVoter(
        string calldata _name,
        uint _age,
        Gender _gender
    ) external isValidAge(_age){
    
        require(isVoterNotRegistered(msg.sender),"You are already registered");
        voterDetails[nextVoterId] = Voter ({
            name:_name,
            age:_age,
            voterId:nextVoterId,
            gender:_gender,
            voteCandidateId:0,
            voterAddress:msg.sender});
            nextVoterId++;
    }

    function getVoterList() public view returns (Voter[] memory) {
         uint lengthArr = nextVoterId-1;
         Voter[] memory voterList = new Voter[](lengthArr);
         for(uint i=0; i<voterList.length;i++){
            voterList[i]=voterDetails[i+1];
         }
         return voterList;
    }

    function castVote(uint _voterId, uint _candidateId) external isVotingOver(){
        require(block.timestamp >= startTime, "Voting has not started yet");
        require(voterDetails[_voterId].voteCandidateId==0,"You have already voted");
        require(voterDetails[_voterId].voterAddress==msg.sender,"You are not authourized");
        require(_candidateId>=1 && _candidateId <3,"Candidate Id is not correct");
        voterDetails[_voterId].voteCandidateId = _candidateId;
        candidateDetails[_candidateId].votes++;
    }

    function setVotingPeriod(uint _startTimeDuration, uint _endTimeDuration) external onlyCommissioner() {
        require(_endTimeDuration>3600,"_endTimeDuration must be greater than 1 hour");
        startTime=1720799550+_startTimeDuration;
        endTime=startTime+_endTimeDuration;
    }

    function getVotingStatus() public view returns (VotingStatus) {
        if(startTime==0){
            return VotingStatus.NotStarted;
        }
        else if(endTime>block.timestamp && stopVoting == false){
            return VotingStatus.InProgress;
        }
        else{
            return VotingStatus.Ended;
        }
    }

    function announceVotingResult() external onlyCommissioner() {
        uint max=0;
        for(uint i=1; i<nextCandidateId; i++){
            if(candidateDetails[i].votes>max){
                max=candidateDetails[i].votes;
                winner=candidateDetails[i].candidateAddress;
            }
        }
    }

    function emergencyStopVoting() public onlyCommissioner() {
       stopVoting = true;
    }
}