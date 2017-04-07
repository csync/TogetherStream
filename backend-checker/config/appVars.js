//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//
var credentials = require("./private/credentials");
var nodemailer = require('nodemailer');

var appVars = {
    serverAddress: credentials.serverAddress,
    accessToken: credentials.accessToken,
    testFBID: credentials.testFBID,
    mail: {
        userName: credentials.email.displayUserName,
        domainName: credentials.email.displayDomainName,
        transporter: nodemailer.createTransport('smtps://' + credentials.email.userName + ':' +
            credentials.email.password + '@' + credentials.email.domainName)
    },
    addressesToNotify: credentials.addressesToNotify
};

module.exports = appVars;
