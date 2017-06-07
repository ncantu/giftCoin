pragma solidity ^0.4.11;

contract Owned {
    
    address masterOwner;
    address owner;
    address winnerAddress;

    function owned() {
        
        owner = msg.sender;
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

contract Coin is Wallet, Influence {
    
    function getRate() returns (uint) public {
        
        weightValueTotal = amountTotalArtefactSell;
        weightValue = amountTotalCoinBuy;
        
        return getWeightValue();
    }
    
    function bidIncrease(address from, address _bidAddress, uint amountIncrease) payable {
        
        from.transfer(amountIncrease);
    }
    
    function buy(address from, address to, uint _amount) payable {
        
        from.transfer(_amount);
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
    string[] categoryNamesCount;
    address[] childsCount;
    address[] listCount;
    
    mapping(string => string) categoryNames;
    mapping(address => Base) childs;
    mapping(address => Base) list;
    
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

contract Personn is Base {
    
    bytes1 personnalCountryIdCardNubmer;
    bytes1[] personnalCountryIdCardNubmers;
    
    function setPersonnalCountryIdCardNubmer(bytes1 _personnalCountryIdCardNubmer){
        
        personnalCountryIdCardNubmer = _personnalCountryIdCardNubmer;
        uint personnalCountryIdCardNubmersCountIndex = personnalCountryIdCardNubmers.length;
        personnalCountryIdCardNubmers[personnalCountryIdCardNubmersCountIndex] = _personnalCountryIdCardNubmer;
    }
}

contract PersonnGroup is Personn  {}

contract Artefact is Base  {
    
    bytes1 artefactSerialNumber;
    bytes1[] public artefactSerialNumbers;
    
    bytes1 imageUrl;
    bytes1[] public imageUrls;
    
    function setArtefactSerialNumber(bytes1 _artefactSerialNumber){
        
        artefactSerialNumber = _artefactSerialNumber;
        uint artefactSerialNumbersCountIndex = artefactSerialNumbers.length;
        artefactSerialNumbers[artefactSerialNumbersCountIndex] = _artefactSerialNumber;
    }
    
    function setImageUrl(bytes1 _imageUrl){
        
        imageUrl = _imageUrl;
        uint imageUrlsCountIndex = imageUrls.length;
        imageUrls[imageUrlsCountIndex] = _imageUrl;
    }
}

contract ArtefactGroup is Base  {}

contract Code is Base {}

contract CodeGroup is Base {}

contract Bid is Base {
    
    uint amountMin;
    uint increaseMax = 0;
    Artefact price;

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
    
    function increase(address _artefactAddress, uint _amountIncrease) returns (bool) {
        
        require(msg.value > increaseMax);
        
        if(expireTest() == true) {
            
            expire();
            transferOwnershipToWinner();
            
            return false;
        }
        increaseMax = _amountIncrease;
        winnerAddress = _artefactAddress;
        
        return true;
    }
}

contract BidGroup is Base {}

contract Grantee is Personn  {}

contract GranteeGroup is PersonnGroup {}

contract Award is Base {}

contract AwardGroup is Base {}

contract CampaignEshop is Base {
    
    BidGroup bidGroup;
    ArtefactGroup artefactGroup;
    
    function setBidGroup(BidGroup _bidGroup) {
        
        bidGroup = _bidGroup;
    }
    
    function setArtefactGroup(ArtefactGroup _artefactGroup){
        
        artefactGroup = _artefactGroup;
    }
    
    function auction() returns (CampaignEshop campaignEshop){
        
        return campaignEshop = this;
    }
    
    function expire(){
        
       for (uint i = 0; i < bidGroup.getListCount(); i++) {
             
            Base bid = bidGroup.getItemById(i);
            bid.expire();
        }
    }
}

contract CampaignEshopGroup is Base {}

contract CampaignOrg is Base {
    
    AwardGroup awardGroup;
    GranteeGroup granteeGroup;
    
    function setAwardGroup(AwardGroup _awardGroup){
        
        awardGroup = _awardGroup;
    }
    
    function setGranteeGroup(GranteeGroup _granteeGroup){
        
        granteeGroup = _granteeGroup;
    }
    
    function distribute() returns (CampaignOrg campaignOrg){
        
        for (uint i = 0; i < awardGroup.getListCount(); i++) {
             
            address addressGrantee = granteeGroup.getItemById(i);
            Base award = awardGroup.getItemById(i);
            
            award.transferOwnership(addressGrantee);
        }
        return this;
    }
}

contract CampaignOrgGroup is Base {}

contract Eshop is PersonnGroup  {
    
    function createArtefact(bytes1 _artefactSerialNumber, bytes1 _imageUrl) 
        returns (Artefact artefact) {
        
        artefact = new Artefact();
        artefact.create(amount, getCategoryNameDefault(), refExtern);
        artefact.setArtefactSerialNumber(_artefactSerialNumber);
        artefact.setImageUrl(_imageUrl);
        
        return artefact;
    }
    
    function createArtefactGroup() 
        returns (ArtefactGroup artefactGroup) {
        
        artefactGroup = new ArtefactGroup();
        artefactGroup.create(amount, getCategoryNameDefault(), refExtern);
        
        return artefactGroup;
    }
    
    function createCode() 
        returns (Code code) {
        
        code = new Code();
        code.create(amount, getCategoryNameDefault(), refExtern);
        
        return code;
    }
    
    function createCodeGroup()  
        returns (CodeGroup codeGroup) {
        
        codeGroup = new CodeGroup();
        codeGroup.create(amount, getCategoryNameDefault(), refExtern);
        
        return codeGroup;
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
    
    function createBidGroup() 
        returns (BidGroup bidGroup) {
        
        bidGroup = new BidGroup();
        bidGroup.create(amount, getCategoryNameDefault(), refExtern);
        
        return bidGroup;
    }
    
    function createCampaignEshop()
        returns (CampaignEshop campaignEshop) {
        
        campaignEshop = new CampaignEshop();
        campaignEshop.create(amount, getCategoryNameDefault(), refExtern);
        
        return campaignEshop;
    }
    
    function createCampaignEshopGroup()
        returns (CampaignEshopGroup campaignEshopGroup) {
        
        campaignEshopGroup = new CampaignEshopGroup();
        campaignEshopGroup.create(amount, getCategoryNameDefault(), refExtern);
        
        return campaignEshopGroup;
    }
    
    function simpleBid (bytes1[] _artefactSerialNumbers, bytes1[] _imageUrls, uint[] _dateStarts, uint[] _durations, uint[] _amountMins)
        returns (Bid bid) {
            
        ArtefactGroup artefactGroup = createArtefactGroup();
        BidGroup bidGroup = createBidGroup();
        uint artefactSerialNumbersLength = _artefactSerialNumbers.length;
        
        for (uint i = 0; i < artefactSerialNumbersLength; i++) {
             
            bytes1 artefactSerialNumber = _artefactSerialNumbers[i];
            bytes1 imageUrl = _imageUrls[i];
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
        simpleBidFinish(artefactGroup, bidGroup);
        
        return bid;
    }
    
    function simpleBidFinish (ArtefactGroup artefactGroup, BidGroup bidGroup) {
            
        CampaignEshop campaignEshop = createCampaignEshop();
        campaignEshop.setArtefactGroup(artefactGroup); 
        
        delete artefactGroup;
        
        campaignEshop.setBidGroup(bidGroup); 
        
        delete bidGroup;
        
        campaignEshop.auction();
        CampaignEshopGroup campaignEshopGroup = createCampaignEshopGroup();
        campaignEshopGroup.addChild(campaignEshop);
        
        delete campaignEshop;
        
        addChild(campaignEshopGroup);
    }
}

contract Org is PersonnGroup  {
    
    function createGrantee(bytes1 _personnalCountryIdCardNubmer) 
        returns (Grantee grantee) {
        
        grantee = new Grantee();
        grantee.create(amount, getCategoryNameDefault(), refExtern);
        grantee.transferOwnership(grantee);
        grantee.setPersonnalCountryIdCardNubmer(_personnalCountryIdCardNubmer);
        
        return grantee;
    }
    
    function createGranteeGroup()
        returns (GranteeGroup granteeGroup) {
        
        granteeGroup = new GranteeGroup();
        granteeGroup.create(amount, getCategoryNameDefault(), refExtern);
        
        return granteeGroup;
    }
    
    function createAward()
        returns (Award award) {
        
        award = new Award();
        award.create(amount, getCategoryNameDefault(), refExtern);
        
        return award;
    }
    
    function createAwardGroup()
        returns (AwardGroup awardGroup) {
        
        awardGroup = new AwardGroup();
        awardGroup.create(amount, getCategoryNameDefault(), refExtern);
        
        return awardGroup;
    }
    
    function createCampaignOrg()
        returns (CampaignOrg campaignOrg) {
        
        campaignOrg = new CampaignOrg();
        campaignOrg.create(amount, getCategoryNameDefault(), refExtern);
        
        return campaignOrg;
    }
    
    function createCampaignOrgGroup()
        returns (CampaignOrgGroup campaignOrgGroup) {
        
        campaignOrgGroup = new CampaignOrgGroup();
        campaignOrgGroup.create(amount, getCategoryNameDefault(), refExtern);
        
        return campaignOrgGroup;
    }
    
    function simpleAward(bytes1[] _personnalCountryIdCardNubmers)
        returns (Award award){
            
        GranteeGroup granteeGroup = createGranteeGroup();
        AwardGroup awardGroup = createAwardGroup();
        
        for (uint i = 0; i < _personnalCountryIdCardNubmers.length; i++) {
            
            bytes1 personnalCountryIdCardNubmer = _personnalCountryIdCardNubmers[i];
            delete _personnalCountryIdCardNubmers[i];
            Grantee grantee = createGrantee(personnalCountryIdCardNubmer);
            granteeGroup.addChild(grantee);
            delete grantee;
            award = createAward();
            awardGroup.addChild(award);
        }
        CampaignOrg campaignOrg = createCampaignOrg();
        campaignOrg.setAwardGroup(awardGroup); 
        delete awardGroup;
        campaignOrg.setGranteeGroup(granteeGroup);
        delete granteeGroup; 
        campaignOrg.distribute();
        CampaignOrgGroup campaignOrgGroup = createCampaignOrgGroup();
        campaignOrgGroup.addChild(campaignOrg);
        delete campaignOrg; 
        addChild(campaignOrgGroup);
        
        return award;
    }
}

contract GiftCoin is Base, Coin {
    
    mapping(address => Org) public orgs;
    mapping(address => Eshop) public eshops;
    mapping(address => Personn) public personns;

    function createOrg()
        public returns (Org org) {
        
        org = new Org();
        org.create(amount, getCategoryNameDefault(), refExtern);
        orgs[org] = org;
        
        return org;
    }
    
    function createEshop()
        public returns (Eshop eshop) {
        
        eshop = new Eshop();
        eshop.create(amount, getCategoryNameDefault(), refExtern);
        eshops[eshop] = eshop;
        
        return eshop;
    }
    
    function createPersonn(bytes1 _personnalCountryIdCardNubmer) 
        public returns (Personn personn) {
        
        personn = new Personn();
        personn.create(amount, getCategoryNameDefault(), refExtern);
        personn.setPersonnalCountryIdCardNubmer(_personnalCountryIdCardNubmer);
        personn.transferOwnership(personn);
        personns[personn] = personn;
        
        return personn;
    }
    
    function orgBuy(address orgAddress, uint _amount) public {
        
        buy(orgAddress, _amount);
    }
    
    function orgSimpleAward(address orgAddress, bytes1[] _personnalCountryIdCardNubmers) public returns (Award award){
        
        Org org = orgs[orgAddress];
        award = org.simpleAward(_personnalCountryIdCardNubmers);
        
        return award;
    }
    
    function eshopSimpleBid(address eshopAddress, bytes1[] _artefactSerialNumbers, bytes1[] _imageURls, uint[] _dateStart, uint[] _duration, uint[] _amountMin) public 
        returns (Bid bid) {
        
        Eshop eshop = eshops[eshopAddress];
        bid = eshop.simpleBid(_artefactSerialNumbers, _imageURls, _dateStart, _duration, _amountMin);
        
        return bid;
    }
    
    function personnBidIncrease(address personnAddress, address _bidAddress, uint amountIncrease) public {

        bidIncrease(personnAddress, _bidAddress, amountIncrease);
    }
}
