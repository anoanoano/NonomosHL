pragma solidity ^0.4.25;

import "./ERC721.sol";
import "./ERC721BasicToken.sol";

/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721HarbergerLicense is ERC721, ERC721BasicToken {
  // Token name
  string internal name_;

  // Token symbol
  string internal symbol_;

  // Mapping from owner to list of owned token IDs
  mapping(address => uint256[]) public ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) public ownedTokensIndex;

  // Mapping from token ID to index of Harlic
  mapping(uint256 => uint256) public tokenHarlic;

  // Mapping from token ID to indices of Taxlog
  mapping(uint256 => uint256) public tokenTaxlog;

  // Array with all token ids, used for enumeration
  uint256[] public allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) public allTokensIndex;

  // Optional mapping for token URIs
  mapping(uint256 => string) public tokenURIs;

  /** EVENTS **/
  event Confiscation(
    address indexed _owner,
    uint256 _tokenId
  );

  /** STRUCTS **/
  struct Harlic {
     uint256 tokenID;
     uint256 turnoverRate; //turnovers per century
     uint256 harlicValue; //in ether
     uint256 publicEquity; //in wei
     uint256 acquisitionsCounter; //counting acquisitions
     address feeBeneficiary;
     string videoID;
  }

  struct Taxlog {
     uint256 tokenID;
     uint256 paidTaxes; //in wei
     uint256 incurredTaxes; //in wei
     uint256 lastTaxationDate;
     uint256 creationDate;
     uint256 presentTaxRate;
     uint256 secondlyTaxRate;

  }

  Harlic[] public harlics;
  Taxlog[] public taxlogs;

    /**
  * @dev Dividend Calculating Variables
  */

  uint256 public totalKReceipts;
  uint256 public payoutsTotal;
  mapping (address => uint256) paymentsFromAddress;
  mapping(address => uint256) payoutsToAddress;

  /**
   * @dev Constructor function
   */
  constructor() public {
    name_ = "HarbergerLicense";
    symbol_ = "HARB";
  }

  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() public view returns (string) {
    return name_;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function symbol() public view returns (string) {
    return symbol_;
  }

  /**
   * @dev Returns an URI for a given token ID
   * @dev Throws if the token ID does not exist. May return an empty string.
   * @param _tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 _tokenId) public view returns (string) {
    require(exists(_tokenId));
    return tokenURIs[_tokenId];
  }

  /**
   * @dev Gets the token ID at a given index of the tokens list of the requested owner
   * @param _owner address owning the tokens list to be accessed
   * @param _index uint256 representing the index to be accessed of the requested tokens list
   * @return uint256 token ID at the given index of the tokens list owned by the requested address
   */
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256)
  {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  /**
   * @dev Gets the total amount of tokens stored by the contract
   * @return uint256 representing the total amount of tokens
   */
  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

  /**
   * @dev Gets the token ID at a given index of all the tokens in this contract
   * @dev Reverts if the index is greater or equal to the total number of tokens
   * @param _index uint256 representing the index to be accessed of the tokens list
   * @return uint256 token ID at the given index of the tokens list
   */
  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

  /**
   * @dev Internal function to set the token URI for a given token
   * @dev Reverts if the token ID does not exist
   * @param _tokenId uint256 ID of the token to set its URI
   * @param _uri string URI to assign
   */
  function _setTokenURI(uint256 _tokenId, string _uri) internal {
    require(exists(_tokenId));
    tokenURIs[_tokenId] = _uri;
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    super.addTokenTo(_to, _tokenId);
    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    super.removeTokenFrom(_from, _tokenId);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  /**
   * @dev Internal function to mint a new token
   * @dev Reverts if the given token ID already exists
   * @param _to address the beneficiary that will own the minted token
   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address _to, uint256 _tokenId) internal {
    super._mint(_to, _tokenId);

    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * @dev Reverts if the token does not exist
   * @param _owner owner of the token to burn
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address _owner, uint256 _tokenId) internal {
    super._burn(_owner, _tokenId);

    // Clear metadata (if any)
    if (bytes(tokenURIs[_tokenId]).length != 0) {
      delete tokenURIs[_tokenId];
    }

    // Reorg all tokens array
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 lastTokenIndex = allTokens.length.sub(1);
    uint256 lastToken = allTokens[lastTokenIndex];

    allTokens[tokenIndex] = lastToken;
    allTokens[lastTokenIndex] = 0;

    allTokens.length--;
    allTokensIndex[_tokenId] = 0;
    allTokensIndex[lastToken] = tokenIndex;
  }

    /**
   * @dev Create a tokenID denoting a license
   * @dev Throws if the token ID already exists.
   * @param _to token owner
   * @param _tokenId token ID, must be unique
   * @param _turnoverRate yearly tax rate as percent.  I.e.: "20" gives a twenty percent yearly rate, calculated per second.  Corresponds to an asset that turns over once every five years (100/20).
   * @param _harlicValue value in Mether of the HarbergerLicense (harlic)
   * @param _publicEquity portion of the equity value, in ether, of the license that is owned by the contract/the public
   * @param _feeBeneficiary beneficiary of HarbergerTaxes (usually same as TokenID owner but allows assignment of revenue stream)
   * @param _tokenURI string name
   */

  function publicMint(      //put into the internal _mint after testing finished
    address _to,
    uint256 _tokenId,
    uint256 _turnoverRate,
    uint256 _harlicValue,
    uint256 _publicEquity, //should be zero unless user donating to public
    address _feeBeneficiary,
    string _tokenURI,
    string _videoID) public returns (bool) {

    require(_turnoverRate >= 0); // as percentage
    require(_publicEquity >= 0 && _publicEquity <= 100); // require percentage

    Harlic memory _harlic = Harlic({
        tokenID: _tokenId,
        turnoverRate: _turnoverRate,
        harlicValue: _harlicValue,
        publicEquity: _publicEquity,
        feeBeneficiary: _feeBeneficiary,
        acquisitionsCounter: 0,
        videoID: _videoID
    });
    harlics.push(_harlic) - 1; //create harlic struct for token

    Taxlog memory _taxlog = Taxlog({
        tokenID: _tokenId,
        paidTaxes: 0,
        incurredTaxes: 0,
        creationDate: now,
        lastTaxationDate: now,
        presentTaxRate: _turnoverRate,
        secondlyTaxRate: 0

    });
    taxlogs.push(_taxlog) - 1; //create taxlog struct for token



    tokenTaxlog[_tokenId] = taxlogs.length - 1; //make record of associated taxlog
    tokenHarlic[_tokenId] = harlics.length - 1; //make record of associated harlic

    _mint(_to, _tokenId); //create token
    _setTokenURI(_tokenId, _tokenURI); //set URI

  }

     /**
   * @dev report new self-assessed value
   * @dev new per-second tax rate immediately goes into effect.
   * @dev causes previous tax rate to "accrue", i.e. be calculated by the calculateTax function
   * @param _tokenId token ID, must be owned by you
   * @param _value new value
   */

  function selfAssess (uint256 _tokenId, uint256 _value)
    public onlyOwnerOf(_tokenId)
    returns (bool) {

    assessTax(_tokenId);

    /*prevent out-of-chronological-order assessments*/
    require(taxlogs[tokenIndex].lastTaxationDate <= now,
    "Assessment cannot happen until after lastTaxationDate");

    /*update self-assessed value*/
    uint256 tokenIndex = allTokensIndex[_tokenId];
    harlics[tokenIndex].harlicValue = _value;


  }

  function changeVideo (uint256 _tokenId, string _videoID)
    public onlyOwnerOf(_tokenId)
    returns (bool) {

    /*update self-assessed value*/
    uint256 tokenIndex = allTokensIndex[_tokenId];
    harlics[tokenIndex].videoID = _videoID;

  }


  function reaffirmValue (uint256 _tokenId) //doesnt require owner of token to call
    internal returns (bool) {

    /*prevent out-of-chronological-order assessments*/
    require(taxlogs[tokenIndex].lastTaxationDate <= now,
    "Assessment cannot happen until after lastTaxationDate");

    /*update self-assessed value with same value*/
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 sameValue = harlics[tokenIndex].harlicValue;
    harlics[tokenIndex].harlicValue = sameValue;

  }

     /**
   * @dev calculate accrued tax, paid or not--i.e. all taxes outside of the period formed by the most recent self-valuation
   */

  function calculateTax(uint256 _tokenId) public returns (uint256) {

    /*tax calculation, working*/
    require(exists(_tokenId) == true);
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 taxSinceLastAssessment;

    uint256 periodValuationMEther = SafeMath.mul(harlics[tokenIndex].harlicValue, 1000000000000000);
    uint256 periodLengthSeconds =
        SafeMath.sub(now, taxlogs[tokenIndex].lastTaxationDate); // in seconds


    uint256 totalTurnovers = harlics[tokenIndex].acquisitionsCounter;

    if (totalTurnovers == 0) {

        uint256 weiPerSecondTax = SafeMath.mul(SafeMath.div(periodValuationMEther, SafeMath.mul(3153600000, harlics[tokenIndex].turnoverRate)), 10000); //seconds in century / turnovers in century
        uint256 creatorIncentive = 0;
    } else {
        weiPerSecondTax = SafeMath.mul(SafeMath.div(periodValuationMEther, SafeMath.mul(3153600000, harlics[tokenIndex].turnoverRate)), 10000); //seconds in century / turnovers in century
        creatorIncentive = SafeMath.sub(1000000000000000000, SafeMath.div(1000000000000000000, harlics[tokenIndex].acquisitionsCounter));
    }

    uint256 decayedWeiPerSecondTax = SafeMath.div(SafeMath.mul(weiPerSecondTax, creatorIncentive), 1000000000000000000);


        taxlogs[tokenIndex].presentTaxRate = weiPerSecondTax; //update taxrate
        //taxlogs[tokenIndex].yearlyTurnovers = turnoversPerYear;
        taxlogs[tokenIndex].secondlyTaxRate = decayedWeiPerSecondTax;

        taxSinceLastAssessment = SafeMath.mul(decayedWeiPerSecondTax, periodLengthSeconds); //deflating

    //taxlogs[tokenIndex].incurredTaxes = allTimeTax;
    return (taxSinceLastAssessment);
  }



     /**
   * @dev force-acquire token. value sent must equal or exceed current value of token less owner's current unpaid taxes
   */

  function acquireToken (uint256 _tokenId)
    public payable returns (bool) {
        assessTax(_tokenId); //update publicEquity value attaching to tokenId's harlic

        uint256 tokenIndex = allTokensIndex[_tokenId];
        uint256 latestSelfAssesedValue = harlics[tokenIndex].harlicValue;
        uint256 acquisitionPrice = SafeMath.sub(SafeMath.mul(latestSelfAssesedValue, 1000000000000000), harlics[tokenIndex].publicEquity); //require acquiror to send harlic value less privateEquity to contract; this value to be forwarded to oldOwner
        uint256 taxPayment = SafeMath.sub(msg.value, acquisitionPrice);
        address oldOwner = ownerOf(_tokenId);
        address newOwner = msg.sender;

        require(msg.value >= acquisitionPrice,
        "You tried to send less than the acquisition price.  Transaction reverted.");
        //require(msg.value <= latestSelfAssesedValue,
        //"You tried to send more than the value of the asset.  Transaction reverted.");
        require(oldOwner != address(0));
        require(newOwner != address(0));

        clearApproval(oldOwner, _tokenId);
        removeTokenFrom(oldOwner, _tokenId);
        addTokenTo(newOwner, _tokenId);

        harlics[tokenIndex].acquisitionsCounter ++;


        //internal payTax function that applies sent value minus acquisition price to taxes
        applyAcquisitionPaymentToTax(_tokenId, taxPayment);
        trackPayments(newOwner, taxPayment);

        //test:
        oldOwner.transfer(acquisitionPrice);

        selfAssess(_tokenId, latestSelfAssesedValue); //reassess token at same value

        emit Transfer(oldOwner, newOwner, _tokenId);

  }


  /**
   * @dev Confiscate token with PublicEquity >= .1ETH
   */
  function confiscateToken (uint _tokenID)
    public returns (bool) {
        uint256 tokenIndex = allTokensIndex[_tokenID];
        bool delinquent = (harlics[tokenIndex].publicEquity > 100000000000000000);
        address owner = ownerOf(_tokenID);
        if (delinquent == true) {

            harlics[tokenIndex].harlicValue = 0;
            harlics[tokenIndex].publicEquity = 0;
            harlics[tokenIndex].videoID = "DRVptF3MG4g";
            taxlogs[tokenIndex].paidTaxes = 0;
            taxlogs[tokenIndex].paidTaxes = 0;
            taxlogs[tokenIndex].incurredTaxes = 0;
            taxlogs[tokenIndex].secondlyTaxRate = 0;

        }

        emit Confiscation(owner, _tokenID);
    }

  /**
   * @dev Public function causing the confiscation of publicEquity corresponding to particular token
   * @dev Sets the value of publicEquity of tokenId's harlic to the current level of unpaid taxes
   * @dev TODO: cause this to presently re-appraise the token at the current value so that recent unpaid taxes accrue.
   */
  function assessTax (uint256 _tokenId)
    public returns (uint256, uint256, uint256) {

        uint256 index = allTokensIndex[_tokenId];
        uint256 taxSinceLastAssessment = calculateTax(_tokenId);

        taxlogs[index].incurredTaxes += taxSinceLastAssessment;

        uint256 paidTaxes = taxlogs[index].paidTaxes;
        uint256 owedTaxes = (taxlogs[index].incurredTaxes - paidTaxes); // not in SafeMath because 0 - 0 was throwing for some reasons
        uint256 publicEquity = owedTaxes; //absolute (wei) publicEquity

        harlics[index].publicEquity = publicEquity;

        //reset lastTaxationDate
        taxlogs[index].lastTaxationDate = now;

        return (paidTaxes, owedTaxes, publicEquity);

    }

        /**
   * @dev value sent with function applied against taxes
   */

  function payTax (uint256 _tokenId)
    public payable returns (bool) {

        uint256 index = allTokensIndex[_tokenId];

        assessTax(_tokenId);

        uint256 oldOwedTaxes = SafeMath.sub(taxlogs[index].incurredTaxes, taxlogs[index].paidTaxes);

        require(msg.value <= oldOwedTaxes,
        "You must not send more than the amount of tax you owe.  You should send a bit less than the amount you owe.");

        taxlogs[index].paidTaxes += msg.value;

        uint256 newOwedTaxes = SafeMath.sub(taxlogs[index].incurredTaxes, taxlogs[index].paidTaxes);

        harlics[index].publicEquity = newOwedTaxes;
    }

  function applyAcquisitionPaymentToTax (uint256 _tokenId, uint256 _taxPayment)
    internal returns (bool) {

        uint256 index = allTokensIndex[_tokenId];

        taxlogs[index].paidTaxes += _taxPayment;
        harlics[index].publicEquity -= _taxPayment;

    }

  /**CUSTOM GETTERS**/

  function getAcquisitionPrice (uint256 _tokenId) public returns (uint256) {
    assessTax(_tokenId); //update publicEquity value attaching to tokenId's harlic

    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 acquisitionPrice = SafeMath.sub(SafeMath.mul(harlics[tokenIndex].harlicValue, 1000000000000000), harlics[tokenIndex].publicEquity);

    return acquisitionPrice;
  }

  function simplePrice (uint256 _tokenId) public view returns (uint256 tIndex, uint256 harlicVal, uint256 pEquity, uint256 aPrice) {

    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 harlicValue = harlics[tokenIndex].harlicValue;
    uint256 publicEquity = harlics[tokenIndex].publicEquity;
    uint256 acquisitionPrice = SafeMath.sub(SafeMath.mul(harlics[tokenIndex].harlicValue, 1000000000000000), harlics[tokenIndex].publicEquity);

    return (tokenIndex, harlicValue, publicEquity, acquisitionPrice);
  }

  function() public payable {

  }

  function trackPayments(address _address, uint256 _amountIn) internal {

      totalKReceipts += _amountIn;
      paymentsFromAddress[_address] += _amountIn;

  }


}
