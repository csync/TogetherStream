/**
 * Created by danielfirsht on 4/17/17.
 */

let csync = require('csync');
let appVars = require('./config/appVars');
let bot = require('./bot');

let participantsKey;
let chatKey;

let contentCleaner = {};

let experationTime = 172800;
let deletionCutoffTime = 30000;
let app = csync({host: appVars.csyncServer, port: appVars.csyncPort, useSSL: false});
let streamPrefix = bot.streamPrefix;

contentCleaner.clean = function () {
    if(app.authData == null) {
        app.authenticate("demo", "demoToken(" + appVars.userToken + ")").then(function(authData){
            contentCleaner.deleteChatLog();
            contentCleaner.deleteParticipantLog();
        }, function(error){
            console.error(error);
        });
    }
    else {
        contentCleaner.deleteChatLog();
        contentCleaner.deleteParticipantLog();
    }
};

contentCleaner.deleteParticipantLog = function () {
    console.log("Starting participant log cleaning");
    participantsKey = app.key(streamPrefix + ".participants.*");
    participantsKey.listen(function(error, value) {
        if (error) {
            console.error(error)
        } else if (value.exists) {
            let currentTime = new Date().getTime() / 1000 - experationTime;
            if(currentTime - value.data.timestamp > 172800) {
                console.log("Deleting participant message at: " + value.key);
                app.key(value.key).delete();
            }
        }
    });
    setTimeout(function () {
        console.log("Stopping listening of participant values for cleaning");
        participantsKey.unlisten()
    }, deletionCutoffTime)
};

contentCleaner.deleteChatLog = function () {
    console.log("Starting chat log cleaning");
    chatKey = app.key(streamPrefix + ".chat.*");
    chatKey.listen(function(error, value) {
        if (error) {
            console.error(error)
        } else if (value.exists) {
            let currentTime = new Date().getTime() / 1000 - experationTime;
            if(currentTime - value.data.timestamp > 172800) {
                console.log("Deleting chat message at: " + value.key);
                app.key(value.key).delete();
            }
        }
    });
    setTimeout(function () {
        console.log("Stopping listening of chat values for cleaning");
        chatKey.unlisten()
    }, deletionCutoffTime)
};

module.exports = contentCleaner;