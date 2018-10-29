pragma solidity ^0.4.18;

library VCGLib1 {

    struct Electorate {

        string electorateName;
        bool listComplete;
        bool ownedList;
        address electorateCreator;
        address[] addressArray;
        mapping (address => bool) membershipCheck;
        uint256 maxNoShows; // this is important.  no showing messes up the system and opens it to exploitation.  must harshly penalize it.
        uint256 perMemberBuyIn;
            //signed ints
        int256 memberCount;

    }

    struct Proposal {

        string proposalDescription;
        uint256 electorateID;
            //signed ints
        int256 neededAmount;
        int256 fairAmount;
        int256 numberOfVotes;
            //unsigned ints
        uint256 postedTime;
        uint256 bidDeadline;
        uint256 revealDeadline;
        mapping (address => bool) voted;
        mapping (address => bool) revealed;
        mapping (address => int256) bid;
        mapping (address => bytes32) hashedBid;
        bool outcomePassed;
        bool resolved;
        address beneficiaryAddress;
            //currently unused
        int256 shortfallTallier;
        uint256 shortBidderCount;

    }

    //     //untested function
    // function corralDelinquents(uint256 _electorate, bool _boot)
    //     public returns (address[] delinquents) {

    //         Electorate storage electorate = electorateList[_electorate];
    //         //delinquents memory = _delinquents[];
    //         uint256 wholeElectorate = electorate.addressArray.length;

    //         if (electorate.ownedList = true) {
    //             require(electorate.electorateCreator == msg.sender,
    //             "This function is restricted to the Group Owner.");
    //         }

    //         for (uint256 i = 0; i<wholeElectorate; i++) {
    //             address _address = electorate.addressArray[i];
    //             if ((electorate.membershipCheck[_address] = true)
    //                 && (electorate.maxNoShows >= noShowCount[_electorate][_address])) {
    //                 delinquents[delinquents.length] = _address;
    //                 if (_boot == true) {
    //                     bootMember(_electorate, _address);
    //                 }
    //             }
    //         }
    //         return delinquents;
    //     }

    //     //untested function
    // function bootMember(uint256 _electorate, address _member)
    //     public {

    //         //boot passed _member address:
    //         electorateList[_electorate].membershipCheck[_member] = false;

    //     }


    //     //withdraw ether from contract

    // function withdrawEtherFromContract (uint256 _withdrawal)
    //     public payable returns (uint256) {

    //             //require no pending bid
    //         require(fundsLockedUnlessZero[msg.sender] == 0);
    //             //require amount withdrawn less than amount deposited
    //         require(_withdrawal <= postedFunds[msg.sender]);
    //             //remit
    //         postedFunds[msg.sender] -= SafeMath.mul(_withdrawal, 1000000000000000);
    //         msg.sender.transfer(SafeMath.mul(_withdrawal, 1000000000000000));

    //     }

    //     //check storage mapping to see how many Ether the user has posted to the contract

    // function checkEtherSentToContract ()
    //     public constant returns (uint256) {

    //         uint256 userFunds = postedFunds[msg.sender];
    //         return userFunds;

    //     }

    //     ///used in js so keep for now

    // function electorateMemberGetter (uint256 _electorateID, uint256 _index)
    //     public constant returns (address[], address) {
    //         return (electorateList[_electorateID].addressArray,
    //                 electorateList[_electorateID].addressArray[_index]);
    //     }

    // function panelProposalsGetter (uint256 _electorateID)
    //     public constant returns (uint256[]) {
    //         return (electorateProposals[_electorateID]);
    //     }


    function getContractBalance ()
        public constant returns (uint256) {
            return address(this).balance;
        }
}
