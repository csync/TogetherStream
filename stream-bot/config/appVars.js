//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//
var credentials = require("./private/credentials");

var appVars = {
    csyncServer: "localhost",
    csyncPort: 6005,
    youtubeKey: credentials.youtube.key,
    userToken: credentials.userToken
};

module.exports = appVars;
