// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./IUSDT.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract RandomNumberGenerator is VRFV2WrapperConsumerBase {

    event RandomNumberRequest(uint256 requestId);
    IUSDT public linkToken;
    address admin;
    address internal linkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address internal VRFWrapper = 0x708701a1DfF4f478de54383E49a627eD4852C816;
    bytes32 internal keyHash;
    uint32 internal fee = 1000000;
    uint32 internal numWords = 1;
    uint16 internal requestConfirmations = 3;
    uint256 internal RoundDown = 1e76;
    uint256 internal myRequestId;
    mapping (uint256 => uint256) internal requestIdToFee;
    mapping (uint256 => uint256) internal requestIdToRandomWord;
    mapping (uint256 => bool) internal requestIdToStatus;
    mapping (address => uint256) internal addressToId;

    constructor () VRFV2WrapperConsumerBase(linkAddress, VRFWrapper){
        linkToken = IUSDT(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        admin = msg.sender;
    }

    function getRandomNumber() public returns ( uint256) {
        uint256 requestId = requestRandomness(fee, requestConfirmations, numWords);
        requestIdToFee[requestId] = VRF_V2_WRAPPER.calculateRequestPrice(fee);
        addressToId[msg.sender] = requestId;
        myRequestId = requestId;
        emit RandomNumberRequest(requestId);
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        require(requestIdToFee[requestId] > 0, "Request not found");
        requestIdToRandomWord[requestId] = randomWords[0];
        requestIdToStatus[requestId] = true;
    }

    function getStatus(uint256 requestId) public view returns(bool){
        return requestIdToStatus[requestId];
    }

    function displayGeneratedRandomWord(uint256 requestId) public view returns(uint256) {
        require(requestIdToFee[requestId] > 0, "Invalid Request ID");
        require(requestIdToStatus[requestId] == true, "Random Number Not gotten YET");
        uint256 result = requestIdToRandomWord[requestId];
        return (result/RoundDown);
        
    }

    function contractBalance() public view returns(uint256){
        return linkToken.balanceOf(address(this));
    }

    function getMyRequestID() public view returns(uint256){
        return addressToId[msg.sender];
    }

    function getLastId() public view returns(uint256){
        return myRequestId;
    }


    function WithdrawLink(uint256 _amount) public {
        require(msg.sender == admin, "Not Admin");
       linkToken.transfer(msg.sender, _amount);
    }

}
   //  keyHash = 0x0476f9a745b61ea5c0ab224d3a6e4c99f0b02fce4da01143a4f70aa80ae76e8a;
       // fee = 0.1 * 10 ** 18;