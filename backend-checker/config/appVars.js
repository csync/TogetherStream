//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//
var credentials = require("./private/credentials");

var appVars = {
    serverAddress: credentials.serverAddress,
    accessToken: credentials.accessToken,
    testFBID: credentials.testFBID
};

module.exports = appVars;
