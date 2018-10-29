//var Supervisor = artifacts.require("./Supervisor.sol");
var SafeMath = artifacts.require("./SafeMath.sol");
var Ownable = artifacts.require("./Ownable.sol");
//var VCGLib1 = artifacts.require("./VCGLib1.sol");
//var VCG_operator = artifacts.require("./VCG_operator.sol");
var ERC721Basic = artifacts.require("./ERC721Basic.sol");
var ERC721 = artifacts.require("./ERC721.sol");
var ERC721Enumerable = artifacts.require("./ERC721.sol");
var ERC721Metadata = artifacts.require("./ERC721.sol");
var ERC721BasicToken = artifacts.require("./ERC721BasicToken.sol");
var ERC721HarbergerLicense = artifacts.require("./ERC721HarbergerLicense.sol");
var ERC721Receiver = artifacts.require("./ERC721Receiver.sol");
var AddressUtils = artifacts.require("./AddressUtils.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.deploy(Ownable);
  //deployer.deploy(VCGLib1);
  deployer.link(SafeMath, [ERC721BasicToken]);
  //deployer.link(Ownable, [Supervisor, VCG_operator]);
  //deployer.link(VCGLib1, [Supervisor, VCG_operator]);
  //deployer.deploy(VCG_operator);
  deployer.deploy(AddressUtils);
  deployer.link(AddressUtils, ERC721BasicToken);
  deployer.deploy(ERC721BasicToken);
  deployer.deploy(ERC721HarbergerLicense);
  //deployer.deploy(ERC721Basic);
}
