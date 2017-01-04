/**
 * Created by danielfirsht on 12/9/16.
 */

var apn = require('apn');
var userController = require('../user/user.controller');
var appVars = require('../config/appVars');
var pg = require('pg');

var invitesService = {};

invitesService.processSendingInvites = function (req, res) {
    userController.getOrCreateStream(req)
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

invitesService.retrieveInvites = function (req, res) {
    getInvites(req.user)
        .then(function (invites) {
            res.json(invites)
        })
};

var sendNotification = function (user, req) {
    var note = new apn.Notification();
    note.badge = req.body["currentBadgeCount"] + 1;
    note.sound = "ping.aiff";
    note.alert = "You've been invited by " + req.body["host"] + "!";
    note.payload = {streamPath: req.body["streamPath"], streamName: req.body["streamName"]};
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

var getInvites = function (user) {
    return new Promise(function (resolve, reject) {
        var client = new pg.Client(appVars.postgres.uri);
        client.connect();
        client.query("SELECT streams.user_id, streams.csync_path, streams.stream_name FROM streams INNER JOIN stream_invites ON streams.id = stream_invites.stream_id WHERE stream_invites.user_id = $1", [user.id],
            function (err, result) {
                if (err) {
                    reject(err);
                }
                else {
                    resolve(result.rows);
                }
            }
        );
    })
};

module.exports = invitesService;