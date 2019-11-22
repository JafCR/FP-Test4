var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var EducationPlatform = artifacts.require("./EducationPlatform.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(EducationPlatform);
};
