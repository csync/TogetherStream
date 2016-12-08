/**
 * Created by danielfirsht on 12/6/16.
 */

var express = require('express');
var authService = require('../auth/auth.service');
var userController = require('../user/user.controller');
var appVars = require('../config/appVars');
var apn = require('apn');

var router = express.Router();

router.use('/device-token', require('./device-token'));

router.post('', authService.isAuthenticated(), function (req, res, next) {
    var users = req.body['users'];
    for(var i = 0; i < users.length; i++) {
        userController.getUserAccountByExternalAccount({id: users[i], provider: 'facebook-token'})
            .then(function (user) {
                var note = new apn.Notification();
                note.badge = 1;
                note.sound = "ping.aiff";
                note.alert = "You've been invited!";
                note.payload = {room: req.body["room"]};
                note.topic = 'com.NTH.stormtrooper';

                var apnProvider = appVars.apn;
                apnProvider.send(note, user.deviceToken).then(function (result) {
                    console.log(result);
                })
            });
    }
    res.sendStatus(200);
});

module.exports = router;