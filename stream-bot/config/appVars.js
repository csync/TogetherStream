//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//
var credentials = require("./private/credentials");

var appVars = {
    csyncServer: credentials.csyncServer,
    csyncPort: credentials.csyncPort,
    youtubeKey: credentials.youtube.key,
    userToken: credentials.userToken
};

module.exports = appVars;
