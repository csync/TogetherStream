//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

var express = require('express');
var userController = require('../user/user.controller');

var router = express.Router();

/**
 * Saves the sent device token for the authenticated user.
 */
router.post("", function (req, res, next) {
    if(!req.body) {
        res.sendStatus(400);
    }
    req.user.deviceToken = req.body['token'];
    userController.saveUser(req.user);
    res.sendStatus(200);
});

module.exports = router;