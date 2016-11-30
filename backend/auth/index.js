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

router.get('/success', authService.handleLoginSuccess);

router.get('/failure', function (req, res, next) {
    res.send("failed to authenticate");
});

router.get('/logout', authService.logout);

router.get('/refresh', authService.refresh);

router.get('/me', authService.isAuthenticated(), function (req, res, next) {
   res.json(req.user);
});

router.get('/facebookfriends', authService.isAuthenticated(), function (req, res, next) {
   var accessToken = req.user.externalAccounts[0].access_token;
   if(accessToken != null) {
       var request = require('request');
       request('https://graph.facebook.com/v2.8/me/friends?access_token=' + accessToken, function (error, response, body) {
           res.send(body);
       })
   }
   else {
       res.status(501).send("not logged in to facebook");
   }
});

module.exports = router;