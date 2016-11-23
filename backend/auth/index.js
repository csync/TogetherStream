/**
 * Created by danielfirsht on 11/22/16.
 */

var express = require('express');
var appVars = require('../config/appVars');
var authService = require('./auth.service');

// Configure Passport
require('./facebook/passport').setup(appVars);

var router = express.Router();

router.use('/facebook', require('./facebook'));

router.get('/success', function (req, res, next) {
    res.send(req.user).end();
});

router.get('/failure', function (req, res, next) {
    res.send("failed to authenticate");
});

// router.get('/me', authService.isAuthenticated(), function (req, res, next) {
//    res.json(req.user);
// });

module.exports = router;