/**
 * Created by danielfirsht on 12/9/16.
 */

var apn = require('apn');
var userController = require('../user/user.controller');
var appVars = require('../config/appVars');

var notificationsService = {};

notificationsService.handleSendingNotifications = function (req, res) {
    var users = req.body['users'];
    for(var i = 0; i < users.length; i++) {
        userController.getUserAccountByExternalAccount({id: users[i], provider: 'facebook-token'})
            .then(function (user) {
                sendNotification(user, req.body["room"]);
            });
    }
    res.sendStatus(200);
};

var sendNotification = function (user, room) {
    var note = new apn.Notification();
    note.badge = 1;
    note.sound = "ping.aiff";
    note.alert = "You've been invited!";
    note.payload = {room: room};
    note.topic = 'com.NTH.stormtrooper';

    var apnProvider = appVars.apn;
    apnProvider.send(note, user.deviceToken).then(function (result) {
        console.log(result);
    })
};

module.exports = notificationsService;