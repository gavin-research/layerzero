// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

//Change this import to the node one if using from a different editor than Remix
import "https://github.com/LayerZero-Labs/solidity-examples/blob/main/contracts/lzApp/NonblockingLzApp.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

//Addresses of both layerzero endpoints on each chain and contracts already deployed with the ABI of this code to already load
//on Remix or similar and play with them.
/*
    LayerZero Goerli Optimism
      lzChainId:10132 lzEndpoint:0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1
      contract: 0x06145eC7c001D08428739a8ccc7AEd3b25214a1d
    LayerZero Goerli
      lzChainId:10121 lzEndpoint:0xbfD2135BFfbb0B5378b56643c2Df8a87552Bfa23
      contract: 0x39B4c23E6888b43F25291BE6Bf0f9B7Fba2ef21e
*/
//
contract LayerZeroTest is NonblockingLzApp {
    string public data = "No permitido";
    address public user;
    uint16 destChainId;
    
    //mapping controlling which address can mint something. 
    //For this, the user will hold or not an NFT on blockchain A, send a message using layerzero to blockchain B, 
    //and in case it is a holder of a specific NFT on A, their address will be saved on B as true in minteamos mapping.
    //Default value is false for all addresses.
    mapping(address => bool) public minteamos;

    //NFT contract direction that will be checked in the send function.
    ERC721 public nftContract = ERC721(0x723d4991793453eac73C3877E9308de1bB7cab86);

    //If the layerzero endpoint is the one on Goerli, mssg will be send to Goerli Optimism and viceversa
    constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {
        if (_lzEndpoint == 0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1) destChainId = 10121;
        if (_lzEndpoint == 0xbfD2135BFfbb0B5378b56643c2Df8a87552Bfa23) destChainId = 10132;
    }

    //Receive function will be executed on the destination blockchain, saving in the mapping minteamos the address
    //of who sent the message from the origin blockchain linked to the possitive or negative permission.
    //For it, it decodes the message sent from the origin blockchain, obtaining the string and the address of the sender address from A
    function _nonblockingLzReceive(uint16, bytes memory, uint64, bytes memory _payload) internal override{
       (user, data) = abi.decode(_payload, (address, string));
       if(keccak256(abi.encodePacked(data)) == keccak256(abi.encodePacked("Permitido"))){
           minteamos[user] = true;
       }
    }

    //Checks if the message sender owns an NFT of the specified contract above.
    //If it is a holder, the function will send the string "Permitido" and the 0x... address of the user.
    //Else, the function will send the string "No permitido" and the 0x... address of the user.
    function send() public payable {
        if (nftContract.balanceOf(msg.sender) > 0) {
                data = "Permitido";
        }else{
            data="No permitido";
        }
        string memory message = data;
        bytes memory payload = abi.encode(msg.sender, message);
        _lzSend(destChainId, payload, payable(msg.sender), address(0x0), bytes(""), msg.value);
             
    }

    //We have to trust the address of the deployed contract in the other blockchain before sending any message.
    //For the contracts' directions here written this step has already done.
    function trustAddress(address _otherContract) public onlyOwner {
        trustedRemoteLookup[destChainId] = abi.encodePacked(_otherContract, address(this));   
    }
}