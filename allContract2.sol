pragma solidity ^0.4.11;

library Convert {
  
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
}

contract Owned {
    
    address masterOwner;
    address owner;
    address winnerAddress;

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
    
    function initWinner(){
        
        winnerAddress = owner;
    }

    function transferOwnershipToWinner() {
        
        owner = winnerAddress;
    }
}

contract Wallet is Owned{

    uint unitTotalArtefactSell = 0;
    uint unitTotalArtefactBuy = 0;
    
    uint amountTotalArtefactSell = 0;
    uint amountTotalArtefactBuy = 0;
    
    uint amountTotalCoinSell = 0;
    uint amountTotalCoinBuy = 0;
    
    uint amount = 0;
    
    function transferOwnership(address newOwner) onlyOwner {
        
        owner = newOwner;
        owner.transfer(amount);
    }
    
    function transferOwnershipToWinner() {
        
        owner = winnerAddress;
        owner.transfer(amount);
    }
    
    function getAmount() returns (uint) {
        
        return amount;
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

contract Expire {
    
    uint expireState = 0; // 0:closed 1:running 2:expired
    uint dateStart = 0;
    uint duration = 0;
    uint amountMin = 0;
    
    function setDateStart(uint _dateStart){
        
        dateStart = _dateStart;
    }
    
    function start(){
        
         if(expireState != 0 && now - dateStart <= duration){
             
            expireState = 1;
         }
         else if(expireState != 0) {
            expire();
         }
    }
    
    function setDuration(uint _duration){
        
        duration = _duration;
    }
    
    function getExpireState() returns (uint) {
        
        return expireState;
    }
    
    function expireTest() returns (bool) {
        
        require(now <= (dateStart + duration));
        
        if(expireState != 2 && expireState != 0){
            
            return true;
        }
        else {
            
            expire();
            return false;
        }
    }
    
    function expire(){
        
        expireState = 2;
    }
    function close(){
        
        expireState = 0;
    }
}

contract Base is Wallet, Influence, Expire {
    
    uint id;
    string refExtern = "default";
    string serialNumber;
    string imageUrl;
    
    string[] categoryNamesCount;
    address[] childsCount;
    address[] listCount;
    
    mapping(string => string) categoryNames;
    mapping(address => Base) childs;
    mapping(address => Base) list;
    
    function setSerialNumber(string _serialNumber){
        
        serialNumber = _serialNumber;
        uint serialNumbersCountIndex = serialNumbers.length;
        serialNumbers[serialNumbersCountIndex] = _serialNumber;
    }
    
    function getSerialNumber() returns (string){
        
        return serialNumber;
    }
    
    function getSerialNumberBytes32() returns (bytes32){
        
        bytes32 a = stringToBytes32(serialNumber);
        
        return a;
    }
    
    function setImageUrl(string _imageUrl){
        
        imageUrl = _imageUrl;
        uint imageUrlsCountIndex = imageUrls.length;
        imageUrls[imageUrlsCountIndex] = _imageUrl;
    }
    
    function getImageUrl() returns (string){
        
        return imageUrl;
    }
    
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
    
    function getCategoryNameDefault() returns (string) {
        
        string index = categoryNamesCount[0];
        
        return categoryNames[index];
    }
    
    function getChildByAddress(address childAddress) returns (Base){
        
        return childs[childAddress];
    }
    
    function getItemByAddress(address itemAddress) returns (Base){
        
        return list[itemAddress];
    }
    
    function getChildById(uint childId) returns (Base){
        
        address childAddress = childsCount[childId];
        
        return childs[childAddress];
    }
    
    function getItemById(uint itemId) returns (Base){
        
        address itemAddress = listCount[itemId];
        
        return list[itemAddress];
    }
    
    function getChildsCount() returns (uint){
        
        return childsCount.length;
    }
    
    function getListCount() returns (uint){
        
        return listCount.length;
    }
    
    function create(uint _amount, string _categoryName, string _refExtern){
        
        categoryNames[_categoryName] = _categoryName;
        uint categoryNamesCountIndex = categoryNamesCount.length;
        categoryNamesCount[categoryNamesCountIndex] = _categoryName;
        amount = _amount;
        refExtern = _refExtern;
        owned();
        list[this] = this;
        uint listCountIndex = listCount.length;
        listCount[listCountIndex] = this;
    }
    
    function addChild(Base child) {

        childs[child] = child;
        uint childsCountIndex = childsCount.length;
        childsCount[childsCountIndex] = child;
        amount += child.getAmount();
    }
}

contract Bid is Base {
    
    uint amountMin;
    uint increaseMax = 0;
    Artefact price;
    uint winnerState = 0; // 0:not awarded 1:awarded
    
    uint winAmountOrgRatio = 100;
    uint winAmountOrgsRatio = 20;
    uint winAmountEshopsRatio = 10;
    uint winAmountContribsRatio = 5;
    
    function getWinnerState() returns (uint) {
        
        return winnerState;
    }
    
    function setWinnerState(uint _state) {
        
        winnerState = _state;
    }
    
    function getWinnerAddress() returns (address) {
        
        require(expireState != 2 && expireState != 0); 
        
        return winnerAddress;
    }
    
    function getWinnerIncrease() returns (uint) {
        
        require(expireState != 2 && expireState != 0); 
        
        return increaseMax;
    }

    function setDateStart(uint _dateStart){
        
        dateStart = _dateStart;
    }
    
    function setPrice(Artefact _artefact){
        
        price = _artefact;
    }
    
    function setAmountMin(uint _amountMin){
        
        amountMin = _amountMin;
        amount = amountMin;
    }
    
    function increase(address _from, uint _amountIncrease) returns (bool) {
        
        if(expireTest() == true) {
            
            expire();
            return true;
        }
        require(_amountIncrease > increaseMax);
        
        increaseMax = _amountIncrease;
        winnerAddress = _from;
        
        return true;
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


contract Coin is MyToken, Wallet, Influence {
    
    struct Member {
        
        mapping(address => uint) addressAmountTotalArtefactSellMap;
        mapping(address => uint) addressDistributeRatioMap;
        mapping(address => uint) addressAmountDistributedMap;
        address[] addressList;
        uint distributeRatio = 0;
        uint AmountTotalArtefactSells = 0;
        string name = '';
        uint id;
    }
    uint[] members;
    mapping(uint => Member) nameMemberMap;
    
    function createMember(string _memberName, _distributeRatio){
    
        uint membersIndex = members.length;
        Member member = new Member({name: _memberName, distributeRatio: _distributeRatio, id: membersIndex});
        members[membersIndex] = member;
    }
    
    function memberAdd(string _memberName, address _memberAddress){
    
        _id = members.length;
        members[_id] = _id;
        nameMemberMap[_id].id = _memberName;
        nameMemberMap[_id].name = _memberName;
        nameMemberMap[_id].addressAmountTotalArtefactSellMap[_memberAddress] = 0;
        nameMemberMap[_id].addressDistributeRatioMap[_memberAddress] = 0;
        nameMemberMap[_id].addressAmountDistributedMap[_memberAddress] = 0;
        uint countChild = nameMemberMap[_id].addressAmountTotalArtefactSells;
        nameMemberMap[_id].addressAmountTotalArtefactSells[countChild] = _memberAddress;
    }
    
    function distribute(_amount) {
        
        for (uint i = 0; i < members.length; i++) {
        
            uint memberId = members[i];
            Member member = nameMemberMap[memberId];
            uint amount = _amount * member.distributeRatio;
            
            for (uint j = 0; j < member.addressList.length; j++) {
            
                address memberAddress = member.addressList[j];
                uint memberAmountTotalArtefactSell = member.addressAmountTotalArtefactSellMap[memberAddress];
                uint memberRatio = (memberAmountTotalArtefactSell / amountTotalArtefactSell) * 100;
                member.addressDistributeRatioMap[memberAddress] = memberRatio;
                uint memberAmountDistributed = amount * memberRatio;
                member.addressAmountDistributedMap[memberAddress] = memberAmountDistributed;
            }
            nameMemberMap[memberId] = member;
        }
    }
    
    function distributeBuy(_toAdderress, _amount) {
        
        uint totalAmount = _amount;
        
        distribute(_amount);
        
        for (uint i = 0; i < members.length; i++) {
        
            uint memberId = members[i];
            Member member = nameMemberMap[memberId];
            string memberName = member.name;
            uint amount = _amount * member.distributeRatio;
            
            for (uint j = 0; j < member.addressList.length; j++) {
            
                address memberAddress = member.addressList[j];
                amoutToDistribute = member.addressAmountDistributedMap[memberAddress];
        
                transferFrom(masterOwner, memberAddress, amoutToDistribute);
        
                totalAmount += amoutToDistribute;
                
                if(memberName == 'valorizators') {
                    
                    member.addressAmountDistributedMap[memberAddress].AmountTotalArtefactSells += _amount;  
                }
            }
            nameMemberMap[memberId] = member;
        }
        totalAmount = totalAmount * getRate();
        
        transferFrom(masterOwner, _toAdderress, totalAmount);
    }
    
    function getRate() public returns (uint) {
        
        weightValueTotal = amountTotalArtefactSell;
        weightValue = amountTotalCoinBuy;
        
        return getWeightValue();
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
    
    string public standard = 'GiftCoin 0.1';
    string public name = 'Gift Coin';
    string public symbol = 'GFT';
    uint8 public decimals = 0;
    
    mapping(address => Personn) public personns;
    mapping(address => Grantee) public grantees;
    mapping(address => Bid) public bids;
    mapping(address => Code) public Code;
    mapping(address => Artefact) public Artefact;
    
    function createMembers(){
        
        createMember('owners', 100);
        createMember('creators', 20);
        createMember('valorizators', 10);
        createMember('operators', 5);
    }
    
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
