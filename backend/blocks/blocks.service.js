/**
 * Created by danielfirsht on 3/7/17.
 */

var apn = require('apn');
var userController = require('../user/user.controller');
var appVars = require('../config/appVars');

var blocksService = {};

blocksService.processCreatingBlock = function (req, res) {
    var blockee = req.body["blockee"];
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

blocksService.retrieveBlocks = function (req, res) {
    getInvites(req.user)
        .then(function (invites) {
            res.json(invites)
        })
};

module.exports = blocksService;