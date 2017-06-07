pragma solidity ^0.4.11;

contract Owned {
    
    address public masterOwner;
    address public owner;
    address  public winnerAddress;
    uint public amount = 0;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
        owner.transfer(amount);
    }
    
    function initWinner(){
        
        winnerAddress = owner;
    }

    function transferOwnershipToWinner() {
        owner = winnerAddress;
        owner.transfer(amount);
    }
}

contract Wallet is Owned{

    uint unitTotalArtefactSell;
    uint unitTotalArtefactBuy;
    
    uint amountTotalArtefactSell;
    uint amountTotalArtefactBuy;
    
    uint amountTotalCoinSell;
    uint amountTotalCoinBuy;
    
    uint amount;
}

contract Influence  {
    
    uint public weightUnit = 0;
    uint public weightValue = 0;
}

contract Expire {
    
    uint expireState; // 0:closed 1:running 2:expired
    uint dateStart;
    uint duration;
    uint amountMin;
    
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
        
        if(expireState != 2 && expireState != 0 && now - dateStart <= duration){
            
            return true;
        }
        else {
            
            expire();
            return false;
        }
    }
    
    function expire(){
        
        if(expireState != 2 && expireState != 0 && now - dateStart > duration){
            
            expireState = 2;
        }
    }
    function close(){
        
        expireState = 0;
    }
}

contract Base is Wallet, Influence, Expire {
    
    uint public id;
    string public refExtern = "default";
    mapping(string => string) public categoryNames;
    mapping(address => Base) public childs;
    mapping(address => Base) public list;
    
    string[] public categoryNamesCount;
    address[] public childsCount;
    address[] public listCount;
    
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
        amount += child.amount();
    }
}

contract Personn is Base {
    
    bytes1 personnalCountryIdCardNubmer;
    bytes1[] public personnalCountryIdCardNubmers;
    
    function setPersonnalCountryIdCardNubmer(bytes1 _personnalCountryIdCardNubmer){
        
        personnalCountryIdCardNubmer = _personnalCountryIdCardNubmer;
        uint personnalCountryIdCardNubmersCountIndex = personnalCountryIdCardNubmers.length;
        personnalCountryIdCardNubmers[personnalCountryIdCardNubmersCountIndex] = _personnalCountryIdCardNubmer;
    }
    
    function bidIncrease(address _codeAddress, address _artefactAddress, uint amountIncrease) {
        
        
    }
    
    function buy(uint _amount) {
        
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
        
        if(expireTest() == true) {
            
            expire();
            transferOwnershipToWinner();
            
            return false;
        }
        if(_amountIncrease > amountMin && _amountIncrease > increaseMax){
            
            increaseMax = _amountIncrease;
            winnerAddress = _artefactAddress;
            
            return true;
        }
        else {
         
            return false;
        }
    }
}

contract BidGroup is Base {}

contract Grantee is Personn  {}

contract GranteeGroup is PersonnGroup {}

contract Award is Base {}

contract AwardGroup is Base {}

contract CampaignEshop is Base {
    
    BidGroup public bidGroup;
    ArtefactGroup public artefactGroup;
    
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
    
    AwardGroup public awardGroup;
    GranteeGroup public granteeGroup;
    
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
    
    function createArtefact(bytes1 _artefactSerialNumber, bytes1 _imageUrl, uint _amount, string _categoryName, string _refExtern) 
        returns (Artefact artefact) {
        
        artefact = new Artefact();
        artefact.create(_amount, _categoryName, _refExtern);
        artefact.setArtefactSerialNumber(_artefactSerialNumber);
        artefact.setImageUrl(_imageUrl);
        
        return artefact;
    }
    
    function createArtefactGroup(uint _amount, string _categoryName, string _refExtern) 
        returns (ArtefactGroup artefactGroup) {
        
        artefactGroup = new ArtefactGroup();
        artefactGroup.create(_amount, _categoryName, _refExtern);
        
        return artefactGroup;
    }
    
    function createCode(uint _amount, string _categoryName, string _refExtern) 
        returns (Code code) {
        
        code = new Code();
        code.create(_amount, _categoryName, _refExtern);
        
        return code;
    }
    
    function createCodeGroup(uint _amount, string _categoryName, string _refExtern) 
        returns (CodeGroup codeGroup) {
        
        codeGroup = new CodeGroup();
        codeGroup.create(_amount, _categoryName, _refExtern);
        
        return codeGroup;
    }
    
    function createBid(uint _dateStart, uint _duration, uint _amountMin, uint _amount, string _categoryName, string _refExtern) 
        returns (Bid bid) {
        
        bid = new Bid();
        bid.create(_amount, _categoryName, _refExtern);
        bid.setDuration(_duration);
        bid.setAmountMin(_amountMin);
        bid.setDateStart(_dateStart);
        bid.initWinner();
        bid.start();
        
        return bid;
    }
    
    function createBidGroup(uint _amount, string _categoryName, string _refExtern) 
        returns (BidGroup bidGroup) {
        
        bidGroup = new BidGroup();
        bidGroup.create(_amount, _categoryName, _refExtern);
        
        return bidGroup;
    }
    
    function createCampaignEshop(uint _amount, string _categoryName, string _refExtern)
        returns (CampaignEshop campaignEshop) {
        
        campaignEshop = new CampaignEshop();
        campaignEshop.create(_amount, _categoryName, _refExtern);
        
        return campaignEshop;
    }
    
    function createCampaignEshopGroup(uint _amount, string _categoryName, string _refExtern)
        returns (CampaignEshopGroup campaignEshopGroup) {
        
        campaignEshopGroup = new CampaignEshopGroup();
        campaignEshopGroup.create(_amount, _categoryName, _refExtern);
        
        return campaignEshopGroup;
    }
    
    function simpleBid (bytes1[] _artefactSerialNumbers, bytes1[] _imageURls, uint[] _dateStart, uint[] _duration, uint[] _amountMin, uint _amount, string _categoryName, string _refExtern)
        returns (Bid bid){
            
        ArtefactGroup artefactGroup = createArtefactGroup(_amount, _categoryName, _refExtern);
        BidGroup bidGroup = createBidGroup(_amount, _categoryName, _refExtern);
        CampaignEshop campaignEshop = createCampaignEshop(_amount, _categoryName, _refExtern);
        CampaignEshopGroup campaignEshopGroup = createCampaignEshopGroup(_amount, _categoryName, _refExtern);
        
        for (uint i = 0; i < _artefactSerialNumbers.length; i++) {
             
            bytes1 artefactSerialNumber = _artefactSerialNumbers[i];
            Artefact artefact = createArtefact(_artefactSerialNumbers[i], _imageURls[i], _amount, _categoryName, _refExtern);
            artefactGroup.addChild(artefact);
            
            bid = createBid(_dateStart[i], _duration[i], _amountMin[i], _amount, _categoryName, _refExtern);
            bid.setPrice(artefact);
            bidGroup.addChild(bid);
        }
        campaignEshop.setArtefactGroup(artefactGroup); 
        campaignEshop.setBidGroup(bidGroup); 
        campaignEshop.auction();
        
        campaignEshopGroup.addChild(campaignEshop);
        
        addChild(campaignEshopGroup);
        
        return bid;
    }
}

contract Org is PersonnGroup  {
    
    function createGrantee(bytes1 _personnalCountryIdCardNubmer, uint _amount, string _categoryName, string _refExtern) 
        returns (Grantee grantee) {
        
        grantee = new Grantee();
        grantee.create(_amount, _categoryName, _refExtern);
        grantee.transferOwnership(grantee);
        grantee.setPersonnalCountryIdCardNubmer(_personnalCountryIdCardNubmer);
        
        return grantee;
    }
    
    function createGranteeGroup(uint _amount, string _categoryName, string _refExtern)
        returns (GranteeGroup granteeGroup) {
        
        granteeGroup = new GranteeGroup();
        granteeGroup.create(_amount, _categoryName, _refExtern);
        
        return granteeGroup;
    }
    
    function createAward(uint _amount, string _categoryName, string _refExtern)
        returns (Award award) {
        
        award = new Award();
        award.create(_amount, _categoryName, _refExtern);
        
        return award;
    }
    
    function createAwardGroup(uint _amount, string _categoryName, string _refExtern)
        returns (AwardGroup awardGroup) {
        
        awardGroup = new AwardGroup();
        awardGroup.create(_amount, _categoryName, _refExtern);
        
        return awardGroup;
    }
    
    function createCampaignOrg(uint _amount, string _categoryName, string _refExtern)
        returns (CampaignOrg campaignOrg) {
        
        campaignOrg = new CampaignOrg();
        campaignOrg.create(_amount, _categoryName, _refExtern);
        
        return campaignOrg;
    }
    
    function createCampaignOrgGroup(uint _amount, string _categoryName, string _refExtern)
        returns (CampaignOrgGroup campaignOrgGroup) {
        
        campaignOrgGroup = new CampaignOrgGroup();
        campaignOrgGroup.create(_amount, _categoryName, _refExtern);
        
        return campaignOrgGroup;
    }
    
    function simpleAward(bytes1[] _personnalCountryIdCardNubmers, uint _amount, string _categoryName, string _refExtern)
        returns (Award award){
            
        GranteeGroup granteeGroup = createGranteeGroup(_amount, _categoryName, _refExtern);
        AwardGroup awardGroup = createAwardGroup(_amount, _categoryName, _refExtern);
        CampaignOrg campaignOrg = createCampaignOrg(_amount, _categoryName, _refExtern);
        CampaignOrgGroup campaignOrgGroup = createCampaignOrgGroup(_amount, _categoryName, _refExtern);
        
        for (uint i = 0; i < _personnalCountryIdCardNubmers.length; i++) {
            
            bytes1 personnalCountryIdCardNubmer = _personnalCountryIdCardNubmers[i];
            Grantee grantee = createGrantee(personnalCountryIdCardNubmer, _amount, _categoryName, _refExtern);
            granteeGroup.addChild(grantee);
            
            award = createAward(_amount, _categoryName, _refExtern);
            awardGroup.addChild(award);
        }
        campaignOrg.setAwardGroup(awardGroup); 
        campaignOrg.setGranteeGroup(granteeGroup); 
        campaignOrg.distribute();
        
        campaignOrgGroup.addChild(campaignOrg);
        
        addChild(campaignOrgGroup);
        
        return award;
    }
}

contract GiftCoin is Base{
    

    
    function createOrg(uint _amount, string _categoryName, string _refExtern)
        returns (Org org) {
        
        org = new Org();
        org.create(_amount, _categoryName, _refExtern);
        
        return org;
    }
    
    function createEshop(uint _amount, string _categoryName, string _refExtern)
        returns (Eshop eshop) {
        
        eshop = new Eshop();
        eshop.create(_amount, _categoryName, _refExtern);
        
        return eshop;
    }
}
