pragma solidity ^0.4.11;

library DataAccess {



  function arrayUintAdd(uint[] _array, uint _data) returns (_array, uint arrayIndex){

    arrayIndex = _array.length;
    _array[arrayIndex] = _data;
  }

  function arrayStringAdd(bytes32[] _array, string _data) returns (_array, uint arrayIndex){

    arrayIndex = _array.length;
    _array[arrayIndex] = DataAcccess.bytes32ToString(_data);
  }

  function mapAddressBaseGet(address[] _array, uint arrayIndex, mapping (address => Base) _map) returns (Base){

    address ref = _array[arrayIndex];
    return _map[ref];
  }

  function mapAddressBaseSet(address[] _array, address _index, Base _item, mapping (address => Base) _map) returns (_map, _array, uint arrayIndex){

    (_array, arrayIndex) = DataAccess.arrayAddessAdd( _array, _index);

    _map[_index] = _item;
  }

  function mapAddressUitGet(address[] _array, uint arrayIndex, mapping (address => uint) _map) returns (uint){

    address ref = _array[arrayIndex];
    return _map[ref];
  }

  function mapAddressUitSet(address[] _array, address _index, uint _item, mapping (address => uint) _map) returns (_map, _array, uint arrayIndex){

    (_array, arrayIndex) = DataAccess.arrayAddessAdd( _array, _index);

    _map[_index] = _item;
  }
}

contract MapStringString {

  bytes32[] count;
  mapping(string => string) map;

  function bytes32ToString(bytes32 x) constant returns (string) {

      bytes memory bytesString = new bytes(32);
      uint charCount = 0;
      for (uint j = 0; j < 32; j++) {
          byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
          if (char != 0) {
              bytesString[charCount] = char;
              charCount++;
          }
      }
      bytes memory bytesStringTrimmed = new bytes(charCount);
      for (j = 0; j < charCount; j++) {
          bytesStringTrimmed[j] = bytesString[j];
      }
      return string(bytesStringTrimmed);
  }

  function stringToBytes32(string memory source) returns (bytes32 result) {
      assembly {
          result := mload(add(source, 32))
      }
  }

  function arrayStringAdd(bytes32[] _array, string _data) returns (_array, uint arrayIndex){

    arrayIndex = _array.length;
    _array[arrayIndex] = DataAcccess.bytes32ToString(_data);
  }

  function set(string _index, string _item) returns (uint arrayIndex){

    arrayIndex = arrayStringAdd(_index);

    map[_index] = _item;
  }

  function get(uint arrayIndex) returns (string){

      string ref = count[arrayIndex];
      return map[ref];
  }

  function getFromIndex(string _index) returns (string){

    return map[_index];
  }
}

contract MapAddressBase {

  address[] count;
  mapping(address => Base) map;

  function arrayAddessAdd(address _data) returns (uint arrayIndex){

    arrayIndex = _array.length;
    count[arrayIndex] = _data;
  }

  function set(address _index, Base _item) returns (uint arrayIndex){

    arrayIndex = arrayAddressAdd(_index);

    map[_index] = _item;
  }

  function get(uint arrayIndex) returns (Base){

    address ref = count[arrayIndex];
    return map[ref];
  }

  function getFromIndex(address _index) returns (Base){

    return map[_index];
  }
}

contract MapAddressUint {

  address[] count;
  mapping(address => uint) map;

  function arrayAddessAdd(address _data) returns (uint arrayIndex){

    arrayIndex = _array.length;
    count[arrayIndex] = _data;
  }

  function set(address _index, uint _item) returns (uint arrayIndex){

    arrayIndex = arrayAddessAdd(_index);

    map[_index] = _item;
  }

  function get(uint arrayIndex) returns (uint){

    address ref = count[arrayIndex];
    return map[ref];
  }

  function getFromIndex(address _index) returns (uint){

    return map[_index];
  }
}


contract Owned {

    address masterOwner;
    address owner;

    function owned() {

        owner = msg.sender;
    }

    function getOwner()
        returns (address) {

        return owner;
    }

    modifier onlyOwner {

        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {

        owner = newOwner;
    }
}

contract Influence  {

    uint weightUnitTotal = 0;
    uint weightValueTotal = 0;

    uint weightUnit = 0;
    uint weightValue = 0;

    function getWeightUnit() returns (uint) {

       return weightUnit / weightValueTotal;
    }

    function getWeightValue() returns (uint) {

       return weightValue / weightValueTotal;
    }
}

contract Expire {

    uint expireState = 0; // 0:created 1:running 2:expired 3:closed
    uint expireDateStart = 0;
    uint expireDuration = 0;
    uint renewOffSet = 0;

    function expireCreate(uint _expireDateStart, uint _expireDuration, uint _renewOffSet){

        expireDateStart = _expireDateStart;
        expireDuration = _expireDuration;
        renewOffSet = _renewOffSet;
    }

    function expireSetDateStart() returns (uint){

        return (expireState + expireDuration)
    }

    function expireGetDateEnd() returns (uint){

        return (expireState + expireDuration)
    }

    function expireTestRenew() {

        expireState = 2;

        if(now > (renewOffSet + expireGetDateEnd())) {

            expireDateStart = now;
            expireState = 1;
        }
    }

    function expireTest() returns (expireState) {

        if(expireState == 0 && expireDateStart != 0 && now > expireDateStart && now < expireGetDateEnd()) {

            expireState = 1;
        }
        if(expireState == 0 && expireDateStart != 0 now > expireDateStart && now > expireGetDateEnd()) {

            expireTestRenew();
        }
        if(expireState == 1 && now > expireGetDateEnd()) {

            expireTestRenew();
        }
        if(expireState == 2) {

            expireTestRenew();
        }
        return expireState;
    }

    function expireClose() {

        expireState = 3;
    }
}

contract Bid is Expire {

    MapAddressUint bidders;

    uint amountMin = 0;
    uint amountMax = 0;
    uint increasedMax = 0;
    uint increasedMin = 0;

    address winAddress;
    uint winAmount = 0;

    function Bid(uint _amountMin, uint _amountMax, uint _increasedMax, uint _increasedMin){

        amountMin = _amountMin;
        amountMin = _amountMax;
        amountMin = _increasedMax;
        amountMin = _increasedMin;
    }

    function increase(address _address, uint _amount){

       require(amountMin < _amount);
       require(expireState == 1);

       testExpire();

       uint arrayIndex = bidders.set(_address, _amount);
       winAddress = _address;
       winAmount = _amount;
    }
}

contract Base is Wallet, Influence, Expire {

    uint id;
    string refExtern;
    string serialNumber;
    string imageUrl;

    MapStringString categories;
    MapAddressBase childs;
    MapAddressBase list;

    function create(uint _id, uint _amount, string _category, string _serialNumber, string _refExtern, string _imageUrl){

        id = _id;
        amount = _amount;
        refExtern = _refExtern;
        serialNumber = _serialNumber;
        imageUrl =_imageUrl;
        setCategoryName(string _categoryName);
    }

    function setChild(string _index, string _item)  returns (uint){

        return childs.set(_index, _item);
    }

    function getChild(uint _arrayIndex)  returns (Base){

        return childs.get(_arrayIndex);
    }

    function getChildFromIndex(address _index)  returns (Base){

        return childs.getFromIndex(_index);
    }

    function setList(string _index, string _item)  returns (uint){

        return list.set(_index, _item);
    }

    function getList(uint _arrayIndex)  returns (Base){

        return list.get(_arrayIndex);
    }

    function getListFromIndex(address _index)  returns (Base){

        return list.getFromIndex(_index);
    }

    function getCategory(uint _arrayIndex) returns (string) {

        return categories.get(_arrayIndex);
    }

    function getCategoryFromIndex(_index) returns (string) {

        return categories.getFromIndex(_index);
    }

    function setCategory(string _name) returns (string) {

        return categories.set(_name);
    }
}


contract Personn is Base {

    address[] grantees;
}

contract Artefact is Base  {}

contract Code is Artefact {

    address[] artefacts;
}

contract Grantee is Personn  {}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract MyToken {
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyToken(uint256 initialSupply) {

        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (_to == 0x0) throw;                               // Prevent transfer to 0x0 address. Use burn() instead
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* Approve and then communicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) throw;                                // Prevent transfer to 0x0 address. Use burn() instead
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;     // Check allowance
        balanceOf[_from] -= _value;                           // Subtract from the sender
        balanceOf[_to] += _value;                             // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) returns (bool success) {
        if (balanceOf[msg.sender] < _value) throw;            // Check if the sender has enough
        balanceOf[msg.sender] -= _value;                      // Subtract from the sender
        totalSupply -= _value;                                // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) returns (bool success) {
        if (balanceOf[_from] < _value) throw;                // Check if the sender has enough
        if (_value > allowance[_from][msg.sender]) throw;    // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        totalSupply -= _value;                               // Updates totalSupply
        Burn(_from, _value);
        return true;
    }
}


contract Cost {

  mapping(address => uint) positifsMap;
  mapping(address => uint) negatifsMap;

  address[] positifsAddress;
  address[] negatifsAddress;

}
contract Transfert {

  uint id;
  address a;
  uint amount;
  uint amountEuro;
  uint amountTotal;
  string state;
  Cost cost;

  uint[] transfertInfoIds;
  mapping(uint => TransfertInfo) transfertInfoMap;
}

contract MemberTypeCollector {

  uint id;
  string name = '';
  uint artefactAmountTotal = 0;
  uint coinAmountTotal = 0;
  uint ratio = 0;
  bool ratioPositif = true;

  string ownersName = 'owners';
  string creatorsName = 'creators';
  string burnersName = 'burners';
  string valorizatorsName = 'valorizators';
  string operatorsName = 'operators';
  string bidWinnersName = 'bidWinners';
  string bidLoosersName = 'bidLoosers';

  mapping(address => uint) addressArtefactAmountTotalMap;
  mapping(address => uint) addressCoinAmountTotalMap;
  address[] addressList;

  mapping(uint => Member) nameMemberMap;
  uint[] memberIds;

  function MemberTypeCollector(){

      createMemberType(ownersName, ownersRatio, ownersRatioPositif);
      createMemberType(burnersName, creatorsRatio, creatorsRatioPositif);
      createMemberType(creatorsName, burnersRatio, burnersRatioPositif);
      createMemberType(valorizatorsName, valorizatorsRatio, valorizatorsRatioPositif);
      createMemberType(operatorsName, operatorsRatio, operatorsRatioPositif);
      createMemberType(bidWinnersName, bidWinnersRatio, bidWinnersRatioPositif);
      createMemberType(bidLoosersName, bidLooserssRatio, bidLooserssRatioPositif);
  }

  function createMemberType(string _memberName, _distributeRatio, bool _ratioPositif){

      uint membersIndex = memberIds.length;
      Member member = new Member({name: _memberName, distributeRatio: _distributeRatio, id: membersIndex: ratioPositif: _ratioPositif});
      memberIds[membersIndex] = membersIndex;
  }

}

contract Coin is MyToken, Wallet, Influence {

    uint public artefactAmountTotalGlobal = 500000;
    uint public coinAmountTotalGlobal = 100000;
    uint public rateMin = (1 / 5);

    uint public ownersRatio = 0;
    uint public creatorsRatio = 10;
    uint public burnersRatio = 20;
    uint public valorizatorsRatio = 1;
    uint public operatorsRatio = 3;
    uint public bidWinnersRatio = 1;
    uint public bidLooserssRatio = 2;

    bool public ownersRatioPositif = true;
    bool public creatorsRatioPositif = true;
    bool public burnersRatioPositif = false;
    bool public valorizatorsRatioPositif = true;
    bool public operatorsRatioPositif = true;
    bool public bidWinnersRatioPositif = true;
    bool public bidLooserssRatioPositif = false;

    function Coin(
        address masterOwner,
        string standard,
        string name,
        string symbol,
        uint8 decimals,
        uint ownersRatio,
        uint creatorsRatio,
        uint burnersRatio,
        uint valorizatorsRatio,
        uint operatorsRatio,
        uint bidWinnersRatio,
        uint bidLooserssRatio,
        uint artefactAmountTotalGlobal,
        uint coinAmountTotalGlobal,
        uint rateMin
    }

    function membersAdd(address _memberAddress){

        for (uint i = 0; i < memberIds.length; i++) {

          nameMemberMap[i].id = _memberName;
          nameMemberMap[i].name = _memberName;
          nameMemberMap[i].artefactAmountTotal = 0;
          nameMemberMap[i].coinAmountTotal = 0;
          nameMemberMap[i].addressArtefactAmountTotalMap[_memberAddress] = 0;
          nameMemberMap[i].addressCoinAmountTotalMap[_memberAddress] = 0;
          nameMemberMap[i].cost.positifsMap[_memberAddress] = 0;
          nameMemberMap[i].cost.negatifsMap[_memberAddress] = 0;
          uint countChild = nameMemberMap[i].addressList;
          nameMemberMap[i].addressList[countChild] = _memberAddress;
      }
    }

    function getTransfertInfo(transfertInfoId) returns (TransfertInfoId) {}

        return transfertInfoMap[transfertInfoId];
    }

    function membersCostAddPositif(transfertInfoId, a) return (TransfertInfoMap transfertInfoMap){

        transfertInfoMap[transfertInfoId].cost.positifsMap[a] += cost;
        uint costIndex = transfertInfoMap[transfertInfoId].cost.positifsAddress.length();
        transfertInfoMap[transfertInfoId].cost.negatifsAddress[costIndex] = a;

        return transfertInfoMap;
    }

    function membersCostAddNegatif(){

      transfertInfoMap[transfertInfoId].cost.negatifsMap[a] += cost;
      uint costIndex = transfertInfoMap[transfertInfoId].cost.negatifsAddress.length();
      transfertInfoMap[transfertInfoId].cost.negatifsAddress[costIndex] = a;
    }

    function distributeBuy(address _toAdderress, uint _amount) returns (uint transfertInfoId) payable {

        uint cost = 0;
        transfertInfoId = transfertInfoIds.length;
        transfertInfoIds[transfertInfoId] = transfertInfoId;
        string state = 'opened';
        TransfertInfo transfertInfo = new TransfertInfo({id: transfertInfoId, a: _toAdderress, state: state});

        // members types
        for (uint i = 0; i < memberIds.length; i++) {

            // members
            for (uint j = 0; j < member.addressList.length; j++) {

                address a = nameMemberMap[i].addressList[j];
                uint coinAmountTotalMap = nameMemberMap[i].addressCoinAmountTotalMap[a];
                uint ratio = coinAmountTotalMap / coinAmountTotal;
                uint amountDistributed = amount * ratio;

                if(memberAddress != _toAdderress) {

                    nameMemberMap[i].addressCoinAmountTotalMap[a] = _amount;

                    if(nameMemberMap[i].ratioPositif == true){

                      transfertInfoMap[transfertInfoId].cost.positifsMap[a] += cost;
                      uint costIndex = transfertInfoMap[transfertInfoId].cost.positifsAddress.length();
                      transfertInfoMap[transfertInfoId].cost.negatifsAddress[costIndex] = a;
                      cost += amountDistributed;
                    }
                    else {

                      transfertInfoMap[transfertInfoId].cost.negatifsMap[a] += cost;
                      uint costIndex = transfertInfoMap[transfertInfoId].cost.negatifsAddress.length();
                      transfertInfoMap[transfertInfoId].cost.negatifsAddress[costIndex] = a;
                      cost -= amountDistributed;
                    }
                }
            }
        }
        uint euro = (_amount + cost) * getRate();
        uint coinAmountTotalGlobal += totalAmount;
        transfertInfoMap[transfertInfoId].amountEuro = euro;
        transfertInfoMap[transfertInfoId].amount = _amount;
        transfertInfoMap[transfertInfoId].amountTotal = _amount + cost;

        return transfertInfoId;
    }

    function distributeBuyValidated(int transfertInfoId) returns (uint) {

      transfertInfoMap[transfertInfoId].state = 'validated';

      transferFrom(masterOwner,  transfertInfoMap[transfertInfoId].a, transfertInfoMap[transfertInfoId].amount);

      for (uint i = 0; i < nameMemberMap[i].cost.positifsAddress.length; i++) {

          aCost = nameMemberMap[i].cost.positifsAddress;
          amountCost = nameMemberMap[i].cost.positifs[aCost];

          transferFrom(masterOwner, aCost, amountCost);
      }

      for (uint i = 0; i < nameMemberMap[o].cost.negatifsAddress.length; i++) {

          aCost = nameMemberMap[i].cost.negatifsAddress;
          amountCost = nameMemberMap[i].cost.negatifs[aCost];

          transferFrom(aCost, masterOwner, amountCost);
      }
      return transfertInfoMap[transfertInfoId].amountEuro;
    }

    function getRate() public returns (uint rate) {

        weightValueTotal = artefactAmountTotalGlobal;
        weightValue = coinAmountTotalGlobal;
        rate = getWeightValue();

        if(rateMin > rate) {

            rate = rateMin;
        }
        return rate;
    }

    function bidIncrease(address _from, address _bidAddress, uint amountIncrease)
        payable returns (bool) {

        Bid bid = bids[_bidAddress];
        bool res = bid.increase(_from, amountIncrease);

        if(res == true && bid.getExpireState() == 2) {

            transferFrom(bid.getWinnerAddress(), bid.getOwner(), bid.getWinnerIncrease());
        }
        return false;
    }

    function bidExpireTest(address _bidAddress) public payable {

        Bid bid = bids[_bidAddress];

        bid.expireTest();

        if(bid.getExpireState() == 2 && bid.getWinnerState() == 0) {

            transferFrom(bid.getWinnerAddress(), bid.getOwner(), bid.getWinnerIncrease());

            bid.setWinnerState(1);
        }
    }

    function buy(address _to, uint _amount) payable {

        transferFrom(masterOwner, _to, _amount);
    }
}

contract GiftCoin is Base, Coin {

    address public masterOwner;
    string public standard = 'GiftCoin 0.1';
    string public name = 'Gift Coin';
    string public symbol = 'GFT';
    uint8 public decimals = 0;

    uint public ownersRatio = 0;
    uint public creatorsRatio = 10;
    uint public burnersRatio = 20;
    uint public valorizatorsRatio = 1;
    uint public operatorsRatio = 3;
    uint public bidWinnersRatio = 1;
    uint public bidLooserssRatio = 2;

    uint public artefactAmountTotalGlobal = 500000;
    uint public coinAmountTotalGlobal = 100000;
    uint public rateMin = (1 / 5);

    mapping(address => Personn) public personns;
    mapping(address => Grantee) public grantees;
    mapping(address => Bid) public bids;
    mapping(address => Code) public Code;
    mapping(address => Artefact) public Artefact;

    function createPersonn(bytes32 _personnalCountryIdCardNubmer) public
        returns (Personn personn) {

        personn = new Personn();
        personn.create(amount, getCategoryNameDefault(), refExtern);
        personn.setPersonnalCountryIdCardNubmer(_personnalCountryIdCardNubmer);
        personn.transferOwnership(personn);
        personns[personn] = personn;

        return personn;
    }

    function personnBuy(address personnAddress, uint _amount) public  payable {

        uint amountPersonn = _amount * buyAmountOrgsRatio / 100;
        uint amountCapitalCreators = _amount * buyAmountEshopsRatio / 100;
        uint amountCapitalOperators = _amount * buyAmountContribsRatio / 100;
        uint amountCapitalvalorizators = (_amount * buyAmountOrgRatio / 100) + amountEshops + amountContribs;

        //amountTotalArtefactSell;
        //weightValue = amountTotalCoinBuy;

        getRate();

        buy(personnAddress, amountOrg);
        // orgs buy(orgAddress, amountEshops);
        // eshops buy(orgAddress, amountEshops);
        // contribs buy(orgAddress, amountContribs);
        amountTotalCoinBuy +=
    }

    function orgSimpleAward(address orgAddress, bytes32[] _personnalCountryIdCardNubmers) public
    returns (Award award){

        Org org = orgs[orgAddress];
        award = org.simpleAward(_personnalCountryIdCardNubmers);
        awards[award] = award;

        return award;
    }

    function eshopSimpleCodes(address eshopAddress, bytes32[] _artefactSerialNumbers, bytes32[] _imageURls, uint[] _artefactAmounts, uint _amount, string _categoryName) public
        returns (Code[] codes){

        for (uint i = 0; i < _artefactSerialNumbers.length; i++) {

            uint artefactAmount = _artefactAmounts[i];
            string memory refExtern = bytes32ToString(_artefactSerialNumbers[i]);
            string memory imageURl = bytes32ToString(_imageURls[i]);

            delete _artefactAmounts[i];
            delete _artefactSerialNumbers[i];
            delete _imageURls[i];

            Code code = new Code();
            code.transferOwnership(eshopAddress);
            code.create(_amount, _categoryName, refExtern);
            uint codeIndex = codes.length;
            Artefact artefact = new Artefact();
            artefact.transferOwnership(eshopAddress);
            artefact.create(artefactAmount, _categoryName, refExtern);
            artefact.setArtefactSerialNumber(refExtern);
            artefact.setImageUrl(imageURl);
            code.addChild(artefact);
            delete artefact;
            codes[codeIndex] = code;
        }
        return codes;
    }

    function eshopSimpleBid(address eshopAddress, bytes32[] _artefactSerialNumbers, bytes32[] _imageURls, uint[] _dateStart, uint[] _duration, uint[] _amountMin) public
        returns (Bid bid) {

        Eshop eshop = eshops[eshopAddress];
        eshop.transferOwnership(eshopAddress);
        bid = eshop.simpleBid(_artefactSerialNumbers, _imageURls, _dateStart, _duration, _amountMin);
        bid.transferOwnership(eshopAddress);
        bids[bid] = bid;

        return bid;
    }

    function eshopSimpleCodesAndBid(address eshopAddress, bytes32[] _artefactSerialNumbers, bytes32[] _imageURls, uint[] _artefactAmounts, uint _amount, string _categoryName, uint[] _dateStart, uint[] _duration, uint[] _amountMin) public
        returns (Bid bid) {

        bytes32[] memory _artefactSerialNumbersReal;
        Code[] memory codes = eshopSimpleCodes(eshopAddress, _artefactSerialNumbers, _imageURls, _artefactAmounts, _amount, _categoryName);

        for (uint i = 0; i < _artefactSerialNumbers.length; i++) {

            Code c = codes[i];
            _artefactSerialNumbersReal[i] = c.getArtefactSerialNumberBytes32();
        }
        bid = eshopSimpleBid(eshopAddress, _artefactSerialNumbersReal, _imageURls, _dateStart, _duration, _amountMin);

        return bid;
    }

    function personnBidIncrease(address _from, address _bidAddress, uint amountIncrease) public payable {

        // uint winBidAmountOrgRatio = 100;
        // uint winBidAmountOrgsRatio = 20;
        // uint winBidAmountEshopsRatio = 10;
        // uint winBidAmountContribsRatio = 5;

        bidIncrease(_from, _bidAddress, amountIncrease);
    }

    function createArtefact(string _artefactSerialNumber, string _imageUrl)
        returns (Artefact artefact) {

        artefact = new Artefact();
        artefact.create(amount, getCategoryNameDefault(), refExtern);
        artefact.setArtefactSerialNumber(_artefactSerialNumber);
        artefact.setImageUrl(_imageUrl);

        return artefact;
    }

    function createBid(uint _dateStart, uint _duration, uint _amountMin)
        returns (Bid bid) {

        bid = new Bid();
        bid.create(amount, getCategoryNameDefault(), refExtern);
        bid.setDuration(_duration);
        bid.setAmountMin(_amountMin);
        bid.setDateStart(_dateStart);
        bid.initWinner();
        bid.start();

        return bid;
    }

    function simpleBid (bytes32[] _artefactSerialNumbers, bytes32[] _imageUrls, uint[] _dateStarts, uint[] _durations, uint[] _amountMins)
        returns (Bid bid) {

        ArtefactGroup artefactGroup = createArtefactGroup();
        BidGroup bidGroup = createBidGroup();

        for (uint i = 0; i < _artefactSerialNumbers.length; i++) {

            string memory artefactSerialNumber = bytes32ToString(_artefactSerialNumbers[i]);
            string memory imageUrl = bytes32ToString(_imageUrls[i]);
            uint dateStart = _dateStarts[i];
            uint duration = _durations[i];
            uint amountMin = _amountMins[i];

            delete _artefactSerialNumbers[i];
            delete _imageUrls[i];
            delete _dateStarts[i];
            delete _durations[i];
            delete _amountMins[i];

            Artefact artefact = createArtefact(artefactSerialNumber, imageUrl);
            artefactGroup.addChild(artefact);
            bid = createBid(dateStart, duration, amountMin);
            bid.setPrice(artefact);
            bidGroup.addChild(bid);
        }

        return bid;
    }

    function createGrantee(bytes32 _personnalCountryIdCardNubmer)
        returns (Grantee grantee) {

        grantee = new Grantee();
        grantee.create(amount, getCategoryNameDefault(), refExtern);
        grantee.transferOwnership(grantee);
        grantee.setPersonnalCountryIdCardNubmer(_personnalCountryIdCardNubmer);

        return grantee;
    }

    function createAward()
        returns (Award award) {

        award = new Award();
        award.create(amount, getCategoryNameDefault(), refExtern);

        return award;
    }

    function simpleAward(bytes32[] _personnalCountryIdCardNubmers)
        returns (Award award){

        for (uint i = 0; i < _personnalCountryIdCardNubmers.length; i++) {

            bytes32 personnalCountryIdCardNubmer = _personnalCountryIdCardNubmers[i];
            delete _personnalCountryIdCardNubmers[i];
            Grantee grantee = createGrantee(personnalCountryIdCardNubmer);
            granteeGroup.addChild(grantee);
            delete grantee;
            award = createAward();
            awardGroup.addChild(award);
        }
        addChild(campaignOrgGroup);

        return award;
    }
}
