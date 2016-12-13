/**
 * Created by danielfirsht on 12/9/16.
 */

var apn = require('apn');
var userController = require('../user/user.controller');
var appVars = require('../config/appVars');
var pg = require('pg');

var invitesService = {};

invitesService.processSendingInvites = function (req, res) {
    userController.getOrCreateStream(req.user)
        .then(function (stream) {
            var users = req.body['users'];
            for(var i = 0; i < users.length; i++) {
                userController.getUserAccountByExternalAccount({id: users[i], provider: 'facebook-token'})
                    .then(function (user) {
                        saveInvite(user, stream);
                        sendNotification(user, req);
                    });
            }
        });

    res.sendStatus(200);
};

var sendNotification = function (user, req) {
    var note = new apn.Notification();
    note.badge = 1;
    note.sound = "ping.aiff";
    note.alert = "You've been invited by " + req.body["host"] + "!";
    note.payload = {room: req.body["stream"]};
    note.topic = 'com.NTH.stormtrooper';

    var apnProvider = appVars.apn;
    apnProvider.send(note, user.deviceToken).then(function (result) {
        console.log(result);
    })
};

var saveInvite = function (user, stream) {
    return new Promise(function (resolve, reject) {
        var client = new pg.Client(appVars.postgres.uri);
        client.connect();
        client.query("INSERT INTO stream_invites (stream_id, user_id) SELECT $1, $2", [stream.id, user.id],
            function (err, result) {
                if (err) {
                    reject(err);
                }
                else {
                    resolve(null);
                }
            }
        );
    })
};

module.exports = invitesService;