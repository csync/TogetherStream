/**
 * Created by danielfirsht on 1/5/17.
 */

var appVars = require('../config/appVars');
var pg = require('pg');
var userController = require('../user/user.controller')

var idService = {};

idService.retrieveExternalIds = function (req, res) {
    userController.getUserByID(req.params['userID'])
        .then(function (user) {
            if(user == null) {
                res.sendStatus(204);
                return
            }
            var ids = {};
            for(var i = 0; i < user.externalAccounts.length; ++i) {
                var account = user.externalAccounts[i];
                ids[account.provider] = account.id;
            }
            res.send(ids);
        }, function (error) {
            res.sendStatus(401);
        })
};

module.exports = idService;