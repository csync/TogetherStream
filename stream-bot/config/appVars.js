//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//
var cfenv = require("cfenv");
var credentials = require("./private/credentials");
var vcapServices = null;
if (process.env.VCAP_SERVICES) {
    vcapServices = JSON.parse(process.env.VCAP_SERVICES);
} else {
  vcapServices = require('./private/VCAP_SERVICES.json');
}

var appEnv = cfenv.getAppEnv();
if (appEnv.isLocal) {
  console.log('Defaulting to local environment config.');
  appEnv = cfenv.getAppEnv({
      vcap: {
          services: vcapServices
      }
  });
  vcapServices = require('./private/VCAP_SERVICES.json');
}

var appVars = {
    port: appEnv.port,
    bind: appEnv.bind,
    csyncServer: "localhost",
    csyncPort: 6005,
    youtubeKey: credentials.youtube.key,
    userToken: credentials.userToken
};

module.exports = appVars;
