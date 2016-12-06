/**
 * Created by danielfirsht on 12/6/16.
 */

var express = require('express');
var userController = require('../user/user.controller');

var router = express.Router();

router.post("", function (req, res, next) {
    if(!req.body) {
        res.sendStatus(400);
    }
    var deviceToken = req.body['token'];
    req.user.deviceToken = deviceToken;
    userController.saveUser(req.user);
    res.sendStatus(200);
});

module.exports = router;