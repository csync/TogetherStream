//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

var express = require('express');
var appVars = require('../config/appVars');
var authService = require('./auth.service');

// Configure Passport
require('./facebook/passport').setup(appVars);
require('./facebook/token/passport').setup(appVars);

var router = express.Router();

router.use('/facebook', require('./facebook'));

router.get('/success', authService.handleLoginSuccess);

router.get('/failure', function (req, res, next) {
    res.send("failed to authenticate");
});

router.get('/logout', authService.logout);

router.get('/refresh', authService.refresh);

module.exports = router;