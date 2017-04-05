//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

var request = require('request');
var appVars = require('./config/appVars');

var serverAddress = appVars.serverAddress;

var backendTests = {};

var testCounter = 0;

var TIMEOUT_TIME = 30000;

backendTests.run = function () {
    console.log("Starting backend-checker");
    runTests()
};

var runTests = function () {
    if(testCounter < backendTests.tests.length) {
        console.log("Running: " + backendTests.tests[testCounter].name);
        backendTests.tests[testCounter]()
            .then(function () {
                testCounter++;
                runTests()
            }, function (error) {
                console.error("Error : " + error)
            })
    }
    else {
        console.log("Finished running tests, no errors found")
    }
};

var refreshTest = function () {
    var endPoint = "/auth/refresh";
    var accessToken = appVars.accessToken;
    return new Promise(function (resolve, reject) {
        request({uri: serverAddress + endPoint + "?access_token=" + accessToken,
            json: true,
            timeout: TIMEOUT_TIME}, function (error, response, data) {
            if(error != null) {
                reject(error)
            }
            else if(response.statusCode != 200) {
                reject("Invalid status code: " + response.statusCode)
            }
            else {
                var accessToken = data.access_token;
                if(accessToken == undefined) {
                    reject("Invalid response")
                }
                else {
                    backendTests.accessToken = accessToken;
                    resolve()
                }
            }
        }
     )}
  );
  
};

var inviteTest = function () {
    var endPoint = "/invites";
    var body = {
        "streamPath": "streams." + appVars.testFBID,
        "streamName": "My Stream",
        "streamDescription": "blah",
        "currentBadgeCount": 1,
        "users": [
            appVars.testFBID
        ],
        "host": "D dog"
    };
    var getInvites = function (resolve, reject) {
        request({uri: serverAddress + endPoint + "?access_token=" + backendTests.accessToken,
                json: true,
                timeout: TIMEOUT_TIME}, function (error, response, data) {
                if(error != null) {
                    reject(error)
                }
                else if(response.statusCode != 200) {
                    reject("Invalid status code: " + response.statusCode)
                }
                else if (data.length == 0 || data[0].csync_path != "streams.115421835667804") {
                    reject("Invalid response: " + data)
                }
                else {
                    deleteInvites(resolve, reject)
                }
            }
        )};

    var deleteInvites = function (resolve, reject) {
        request({uri: serverAddress + endPoint + "?access_token=" + backendTests.accessToken,
                json: true,
                method: "DELETE",
                timeout: TIMEOUT_TIME}, function (error, response, data) {
                if(error != null) {
                    reject(error)
                }
                else if(response.statusCode != 200) {
                    reject("Invalid status code: " + response.statusCode)
                }
                else {
                    resolve()
                }
            }
        )};

    return new Promise(function (resolve, reject) {
        request({uri: serverAddress + endPoint + "?access_token=" + backendTests.accessToken,
                json: true,
                method: "POST",
                body: body,
                timeout: TIMEOUT_TIME}, function (error, response, data) {
                if(error != null) {
                    reject(error)
                }
                else if(response.statusCode != 200) {
                    reject("Invalid status code: " + response.statusCode)
                }
                else {
                    getInvites(resolve, reject)
                }
            }
        )}
    );
};

var blockTest = function () {
    var endPoint = "/blocks"
};

backendTests.tests = [refreshTest, inviteTest];

module.exports = backendTests;