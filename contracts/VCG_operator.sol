pragma solidity >=0.6.0 <0.8.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./VCGLib1.sol";

contract VCG_operator {
    using SafeMath for uint256;

        //** STORAGE **//

        //general
    VCGLib1.Electorate[] public electorateList;
    VCGLib1.Proposal[] public proposalList;
        //proposal info
    mapping (uint256 => uint256) public proposalElectorateMap;
    mapping (uint256 => int256) public proposalBidCounter;
    mapping (uint256 => int256) public revealedBids;
        //user info
    mapping (address => int256) public postedFunds;
    mapping (address => int256) public retainedTax;
    mapping (address => int256) public outstandingTax;
    mapping (address => int256) public paidDues;
    mapping (address => int256) public outstandingDues;
    mapping (address => uint32) public fundsLockedUnlessZero;
    mapping (uint256 => mapping(address => bool)) public settleUpRecords;
        //electorate info
    mapping (uint256 => mapping (address => uint256)) public noShowCount; //number of noShows that gets you kicked from group
        //list of pending proposals by address, electorate
    mapping (address => uint256[]) public addressProposals;
    mapping (uint256 => uint256[]) public electorateProposals;


        //** EVENTS **//

    event electorateCreated (
        string electorateName,
        uint256 electorateID
        );

    event blindBidSubmitted (
        string electorateName,
        uint256 electorateID,
        uint256 proposalID,
        bytes32 hashedBid
        );

        //** FUNCTIONS **//

    function createProposal (string _proposalDescription,
        int256 _neededAmount,
        uint256 _electorateID,
        uint256 _bidDeadline,
        uint256 _revealDeadline,
        address _beneficiaryAddress)
        public {

            VCGLib1.Proposal memory _proposal;

            _proposal.proposalDescription = _proposalDescription;
            _proposal.neededAmount = (_neededAmount * 1000000000000000);
            _proposal.electorateID = _electorateID;
            _proposal.beneficiaryAddress = _beneficiaryAddress;
            _proposal.postedTime = now;
            _proposal.bidDeadline = _bidDeadline;
            _proposal.revealDeadline = _revealDeadline;

            require(SafeMath.sub(_revealDeadline, _bidDeadline) > 86400,
                "Reveal deadline must be at least 24 hours after bid deadline.");

            proposalList.push(_proposal);

            uint256 _ID = proposalList.length-1;
            electorateProposals[_electorateID].push(_ID);

    }

    function createElectorate (string _electorateName,
        bool _ownedList)
        public
        returns (uint256) {

            VCGLib1.Electorate memory _electorate;

            _electorate.electorateName = _electorateName;
            _electorate.ownedList = _ownedList;
            _electorate.electorateCreator = msg.sender;
            _electorate.addressArray = new address[](0);
            _electorate.memberCount = 0;


            electorateList.push(_electorate);

            emit electorateCreated(
                _electorateName,
                electorateList.length-1
            );

            return electorateList.length-1;

    }

    function addToElectorate (uint256 _electorateID,
        address _voterToAdd)
        public returns (bool success) {

            VCGLib1.Electorate storage electorate = electorateList[_electorateID];


                //throw if sender not required owner of electorate

            if (electorate.ownedList == true) {
                require(electorate.electorateCreator == msg.sender);
            }
                //throw if voter already in electorate
            require(electorate.membershipCheck[_voterToAdd] == false);

                //add voter

            electorate.addressArray.push(_voterToAdd);
            electorate.membershipCheck[_voterToAdd] = true;
            electorate.memberCount++;

            return success = true;

    }

    function closeElectorate (uint256 _electorateID)
        public returns (bool success) {

            VCGLib1.Electorate storage electorate = electorateList[_electorateID];

            if (electorate.ownedList == true) {
                require(electorate.electorateCreator == msg.sender);
            }

            electorate.listComplete = true;

            return true;
        }

    function conductBlindVote(uint256 _proposalID, bytes32 _hashedBid)
        public payable returns (bool voteClosed) {

            address voter = msg.sender;
            uint256 electorateKey = proposalList[_proposalID].electorateID;
            int256 wholeElectorate = electorateList[electorateKey].memberCount;
            int256 fairVal = (proposalList[_proposalID].neededAmount / wholeElectorate);

            require(electorateList[electorateKey].membershipCheck[voter] == true,
                "User must be a Group Member to bid.");
            require(electorateList[electorateKey].listComplete == true,
                "Group must be closed before bidding may take place.");
            require(proposalList[_proposalID].voted[voter]==false,
                "User already bid on this Proposal.");
            require(postedFunds[msg.sender] >= fairVal,
                    "User must stake the 'fair' value of the Proposal to the contract (proposal cost/group members) in order to bid.");

            proposalList[_proposalID].voted[voter] = true;
            proposalList[_proposalID].numberOfVotes ++;
            proposalList[_proposalID].hashedBid[voter] = _hashedBid;

            //add one to fundsLockedUnlessZero
            fundsLockedUnlessZero[voter] ++;

            if (proposalList[_proposalID].numberOfVotes == wholeElectorate) {
                    //call closeVote() function
                closeVote(_proposalID);
                return true;
            } else {
                return false;
            }


    }

        /*vote function without blinding, for testing*/

    function conductNonBlindVote(uint256 _proposalID)
        public payable returns (bool voteClosed) {

            address voter = msg.sender;
            uint256 proposalID = _proposalID;
            int256 amountValued = int(msg.value);
            uint256 electorateKey = proposalList[proposalID].electorateID;
            int256 wholeElectorate = electorateList[electorateKey].memberCount;

            require(electorateList[electorateKey].membershipCheck[voter] == true);
            require(electorateList[electorateKey].listComplete == true);
            require(proposalList[proposalID].voted[voter]==false);

            proposalList[proposalID].voted[voter] = true;
            proposalList[proposalID].numberOfVotes ++;
            proposalList[proposalID].bid[msg.sender] += amountValued;
            proposalBidCounter[proposalID] += amountValued;
            postedFunds[msg.sender] += amountValued;


            if (proposalList[proposalID].numberOfVotes == wholeElectorate) {
                    //call closeVote() function
                closeVote(proposalID);
                    //call tallyBids() function
                tallyBids(proposalID);
                return true;
            } else {
                return false;
            }


    }

    function closeVote(uint256 _propID)
        internal returns (int256 fairAmount) {

          uint256 electorateKey = proposalList[_propID].electorateID;
          int256 wholeElectorate = electorateList[electorateKey].memberCount;

          fairAmount = (proposalList[_propID].neededAmount / wholeElectorate);
          proposalList[_propID].fairAmount = fairAmount;

          return (fairAmount);

        }

    // function getContractBalance ()
    //     public constant returns (uint256) {
    //         return address(this).balance;
    //     }
    function getKBal ()
        public constant returns (uint256 _money) {
            return VCGLib1.getContractBalance();
    }

    function revealBid (uint256 _propID, int256 _bidReveal)
        public payable returns (bool, uint256) {

            //check hash, not already revealed, deposit >= bid
            require(keccak256(abi.encodePacked(_bidReveal))
                == proposalList[_propID].hashedBid[msg.sender],
                "This bid does not match your blind bid.  You may try again.");
                //NEW!
            require(proposalList[_propID].revealed[msg.sender] == false,
                "Your blind bid on this proposal has already been revealed.");
                //NEW!
            require(postedFunds[msg.sender] >= _bidReveal,
                "You may not bid more Ether than you have deposited. Please deposit additional Ether to the contract, and then reveal your Bid.");

            //tally up bid
            proposalList[_propID].bid[msg.sender] += (_bidReveal * 1000000000000000);
            proposalBidCounter[_propID] += (_bidReveal * 1000000000000000);
            revealedBids[_propID] ++;

            //keep track of total short bid shortfall
            //in the event tax must be taken from more than one long bidder,
            //this is the excess above fair that must be collected from long bidders
            // if (proposalList[_propID].bid[msg.sender] < proposalList[_propID].fairAmount) {
            //     proposalList[_propID].shortBidShortfallTallier +=
            //         SafeMath.sub(proposalList[_propID].fairAmount, proposalList[_propID].bid[msg.sender]);
            //     proposalList[_propID].shortBidderCount ++;

            //     //keep track of longBidderExcess
            // } else if (proposalList[_propID].bid[msg.sender] > proposalList[_propID].fairAmount) {
            //     proposalList[_propID].longBidExcessTallier +=
            //         SafeMath.sub(proposalList[_propID].bid[msg.sender], proposalList[_propID].fairAmount);
            // }

            //pass to payout if this is the last bid
            if (revealedBids[_propID] == proposalList[_propID].numberOfVotes) {
                tallyBids(_propID);
            } // *!* here, add an 'else' clause resolving if time's up for bid reveals


            //reduce fundsLockedUnlessZero by one
            fundsLockedUnlessZero[msg.sender] --;

            return (true, _propID);

        }

    function closeBiddingAtDeadline (uint256 __propID)
        public returns (bool) {
        //invoke closeVote function
        //(thus calculating fairAmount and readying proposal for reveal phase)
        //when time limit is up

    }

    function closeRevealingAtDeadline (uint256 __propID)
        public returns (bool) {
        //invoke tallyBid function
        //(thus closing/executing the proposal)
        //when time limit is up (in case not everyone who voted revealed in time)

    }

    function tallyBids (uint256 _propID)
        internal returns (bool) {

                //vars
            address beneficiary = proposalList[_propID].beneficiaryAddress;

                //check if passed
            if (proposalBidCounter[_propID] >= proposalList[_propID].neededAmount) {
                proposalList[_propID].outcomePassed = true;
                if (int(address(this).balance) >= proposalBidCounter[_propID]) {
                    beneficiary.transfer(uint(proposalList[_propID].neededAmount));
                } else {
                    beneficiary.transfer(uint(proposalBidCounter[_propID]));
                }
            } else {
                proposalList[_propID].outcomePassed = false;
            }

            //call settleUpAll

            settleUpAll(_propID);

        }

    function settleUpAll(uint256 _propID)
        internal returns (bool) {

            //vars

            uint256 electorateKey = proposalList[_propID].electorateID;
            uint256 wholeElectorate = electorateList[electorateKey].addressArray.length; //recall this may include kicked out members

            //call settleUp for each electorate member
            for (uint256 i = 0; i<wholeElectorate; i++) {
                address _address = electorateList[electorateKey].addressArray[i];
                if (electorateList[electorateKey].membershipCheck[_address] = true) {
                    addressProposals[_address].push(_propID);
                    settleUp(_propID, _address);
                }
            }
    }

    function settleUp(uint256 _propID, address _settlingAddress)
        internal returns (bool pivotal, bool exceedsFair, bool pswoutbdr, int256, int256) {


            //find out what to tax and pay out and execute it
            VCGLib1.Proposal storage proposal = proposalList[_propID];
            int256 settlerBid = proposal.bid[_settlingAddress];
            int256 totalBid = proposalBidCounter[_propID];
            bool passedWithoutBidder = ((totalBid - settlerBid) > proposal.neededAmount);
            bool passedIfBidderBidFair =
                ((totalBid - settlerBid + proposal.fairAmount) > proposal.neededAmount);
            exceedsFair = (settlerBid > proposal.fairAmount);

            //require that proposal has been closed
            //and hasn't been prior settleup
            //and hashed bid is correct
            require(proposal.fairAmount != 0);
            require(settleUpRecords[_propID][_settlingAddress] == false);


                //determine if voter pivotal, send to calculate tax if bid more than fair

            if ((proposal.outcomePassed == true) && (passedWithoutBidder == false)
                && (exceedsFair == true)) {
                pivotal = true;

                //postedFunds[_settlingAddress] -= proposal.fairAmount; //reduces balance by retained bid
                //paidDues[_settlingAddress] += proposal.fairAmount;

                calculatePassTax(_propID, _settlingAddress); //invoke tax function

            } else if ((proposal.outcomePassed == true) && (passedWithoutBidder == false)
                && (exceedsFair == false)) {
                pivotal = true;

                    //don't invoke tax function bc no negative externality imposed
                //paidDues[_settlingAddress] += settlerBid;
                //outstandingDues[_settlingAddress] += SafeMath.sub(proposal.fairAmount, settlerBid);
                //postedFunds[_settlingAddress] -= settlerBid; //reduces balance by retained bid
                //proposal.shortfallTallier += SafeMath.sub(proposal.fairAmount, settlerBid);

                //calculatePassTax(_propID, _settlingAddress);
                int256 balance = postedFunds[_settlingAddress];

                exceedsFair = false;
                if (balance >= proposal.fairAmount) {
                    postedFunds[_settlingAddress] -= proposal.fairAmount;
                    paidDues[_settlingAddress] += proposal.fairAmount;
                } else if (balance < proposal.fairAmount) {
                    outstandingDues[_settlingAddress] += (proposal.fairAmount - settlerBid); //outstandingDues: deficit vs fair, less retained balance
                    paidDues[_settlingAddress] += balance;
                    postedFunds[_settlingAddress] = 0;
                }

            } else if ((proposal.outcomePassed == false) && (passedIfBidderBidFair == true)) {
                pivotal = true;

                    //invoke tax function
                calculateFailTax(_propID, _settlingAddress);

            } else if ((proposal.outcomePassed == false) && (passedIfBidderBidFair == false)) {

                pivotal = false;
               /*auction failed and no single party responsible;
               no penalty; do nothing, leave funds in K,
               bidder can now withdraw them*/


            } else if (((proposal.outcomePassed == true) && (passedWithoutBidder == true))
                && ((exceedsFair == true))) {
                pivotal = false;

                /*do not refund, but bidder can now withdraw balance*/
                // uint256 refund = SafeMath.sub(settlerBid, proposal.fairAmount);
                // _settlingAddress.transfer(refund);

                /*!!!!build new function here that divvies pro rata the shortbid shortfall, below
                and levies tax consisting of part of excess bid!!!*/

                paidDues[_settlingAddress] += proposal.fairAmount;
                postedFunds[_settlingAddress] -= proposal.fairAmount; //reduces balance by fairAmount
                //build function that credits excess bid to outstandingTax/Dues and run here

                //voter not pivotal, prop passed, but bid does NOT exceed fair
                //thus there is a deficit to track
                //track defict as outstanding tax

            } else if (((proposal.outcomePassed == true) && (passedWithoutBidder == true))
                && ((exceedsFair == false))) {
                pivotal = false;

                proposal.shortfallTallier += (proposal.fairAmount - settlerBid);
                    //**eventually make a function that automatically settles outstandingTax
                    //**when function called
                    /*tax in this situation should be part of bidder shortfall, not all*/

                outstandingDues[_settlingAddress] += (proposal.fairAmount - settlerBid); //currently levies whole shortfall as tax
                paidDues[_settlingAddress] += settlerBid;
                postedFunds[_settlingAddress] -= settlerBid; //reduces balance by retained bid

            } else {
                pivotal = false;
            }

        //prevent double-call
        settleUpRecords[_propID][_settlingAddress] = true;
        return (pivotal, exceedsFair, passedWithoutBidder, totalBid-settlerBid, settlerBid);


    }

    function calculateFailTax (uint256 _propID, address _taxee)
        internal returns (bool, int256) {

            // check
        require(proposal.outcomePassed == false);

            //variable setup
        VCGLib1.Proposal storage proposal = proposalList[_propID];
        int256 balance = postedFunds[_taxee];
        int256 senderBid = proposal.bid[_taxee];
        int256 totalBid = proposalBidCounter[_propID];
        int256 wholeElectorate = electorateList[proposal.electorateID].memberCount;
        int256 failTax =
            ((totalBid - senderBid) - ((wholeElectorate-1) * proposal.fairAmount));

                /*user pivotal, prop not passed, bid exceeds failtax
                retain failtax, return rest of bid
                record retained*/
            if (balance >= failTax) {

                bool exceedsFair = false;
                postedFunds[_taxee] -= failTax; //subtract tax from balance
                retainedTax[_taxee] += failTax; //record tax

                return (exceedsFair, failTax);


                /*user pivotal, prop not passed, and tax exceeds bid
                retain bid as tax
                record outstandingTax*/
            } else if (failTax > balance) {

                exceedsFair = false;

            //6-12: this should simply zero out balance and add tax-balance to outstandingTax

                retainedTax[_taxee] += balance; //retain whole bid
                outstandingTax[_taxee] += (failTax - balance); //debit tax owed over and above bid
                postedFunds[_taxee] = 0; //zero out

                return (exceedsFair, failTax);

                //this shoud never get called
            } else {

                return (exceedsFair, failTax);

            }

    }

    function calculatePassTax (uint256 _propID, address _taxee)
        internal returns (bool) {

            //variable setup
        VCGLib1.Proposal storage proposal = proposalList[_propID];
        int256 senderBid = proposal.bid[_taxee];
        int256 totalBid = proposalBidCounter[_propID];
        int256 wholeElectorate = electorateList[proposal.electorateID].memberCount;
        //uint256 excess = SafeMath.sub(senderBid, proposal.fairAmount);
        int256 balance = postedFunds[_taxee];


        /*handle edge case where fairTimesAllButOne exceeds totalMinusSender*/
        //calculate tax for passed proposal
        if ((totalBid-senderBid)/(wholeElectorate-1) < proposal.fairAmount) {
            int256 passTax =
                ((proposal.fairAmount * (wholeElectorate-1)) - (totalBid - senderBid));
        } else {
            passTax = 0;
        }


            //gut check
        require (proposal.outcomePassed == true);

                // user pivotal, prop passed, and bid exceeds fair
            if ((senderBid >= proposal.fairAmount)
                && (balance >= (proposal.fairAmount + passTax))) {

                bool exceedsFair = true;
                postedFunds[_taxee] -= (proposal.fairAmount + passTax); //decredit balance
                retainedTax[_taxee] += passTax; //record retained tax
                paidDues[_taxee] += proposal.fairAmount;

                return (exceedsFair);

            } else if ((senderBid >= proposal.fairAmount)
                && (balance < (proposal.fairAmount + passTax))) {

                exceedsFair = true;

                if (balance >= proposal.fairAmount) {
                    paidDues[_taxee] += proposal.fairAmount;
                    retainedTax[_taxee] += (balance - proposal.fairAmount);
                    outstandingTax[_taxee] +=
                      (passTax - (balance - proposal.fairAmount));

                   postedFunds[_taxee] = 0; //clear out balance

                } else if (balance < proposal.fairAmount) {
                    paidDues[_taxee] += balance;
                    outstandingDues[_taxee] += (proposal.fairAmount - balance);
                    outstandingTax[_taxee] += passTax;

                    postedFunds[_taxee] = 0; //clear out balance

                }

                return (exceedsFair);
            }
    }

    function depositEtherToContract (uint256 _deposit)
        public payable returns (uint256) {

            require(msg.value == SafeMath.mul(_deposit, 1000000000000000)); //
            postedFunds[msg.sender] += int(msg.value);
            return msg.value;

        }

    function()
        public payable {

            postedFunds[msg.sender] += int(msg.value);

        }


    //     //untested function
    // function corralDelinquents(uint256 _electorate, bool _boot)
    //     public returns (address[] delinquents) {

    //         VCGLib1.Electorate storage electorate = electorateList[_electorate];
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


        //withdraw ether from contract

    function withdrawEtherFromContract (int256 _withdrawal)
        public payable returns (uint256) {

                //require no pending bid
            require(fundsLockedUnlessZero[msg.sender] == 0);
                //require amount withdrawn less than amount deposited
            require(_withdrawal <= postedFunds[msg.sender]);
                //remit
            postedFunds[msg.sender] -= (_withdrawal * 1000000000000000);
            msg.sender.transfer(uint(_withdrawal * 1000000000000000));

        }

        //check storage mapping to see how many Ether the user has posted to the contract

    function checkEtherSentToContract ()
        public constant returns (int256) {

            int256 userFunds = postedFunds[msg.sender];
            return userFunds;

        }

        ///used in js so keep for now

    function electorateMemberGetter (uint256 _electorateID, uint256 _index)
        public constant returns (address[], address) {
            return (electorateList[_electorateID].addressArray,
                    electorateList[_electorateID].addressArray[_index]);
        }

    function panelProposalsGetter (uint256 _electorateID)
        public constant returns (uint256[]) {
            return (electorateProposals[_electorateID]);
        }

    function closedProposalsGetterByAddress (address _user)
        public constant returns (uint256[]) {
            return (addressProposals[_user]);
        }

}
