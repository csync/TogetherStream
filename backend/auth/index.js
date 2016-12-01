/**
 * Created by danielfirsht on 11/22/16.
 */

var express = require('express');
var appVars = require('../config/appVars');
var authService = require('./auth.service');

// Configure Passport
require('./facebook/passport').setup(appVars);
require('./youtube/passport').setup(appVars);

var router = express.Router();

router.use('/facebook', require('./facebook'));
router.use('/youtube', require('./youtube'));

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
    var fbAccount = req.user.externalAccounts[0];
    var securityHelper = require('./security.helper');
    var credentials = require('../config/credentials');
    var accessToken = securityHelper.decrypt(fbAccount.access_token, credentials.app.accessTokenKey, fbAccount.at_iv, fbAccount.at_tag);
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

router.get('/ytplaylists', authService.isAuthenticated(), function (req, res, next) {
    var ytAccount = req.user.externalAccounts[0];
    var securityHelper = require('./security.helper');
    var credentials = require('../config/credentials');
    var accessToken = securityHelper.decrypt(ytAccount.access_token, credentials.app.accessTokenKey, ytAccount.at_iv, ytAccount.at_tag);
    if(accessToken != null) {
        var request = require('request');
        request('https://www.googleapis.com/youtube/v3/playlists?part=snippet&mine=true&access_token=' + accessToken, function (error, response, body) {
            res.send(body);
        })
    }
    else {
        res.status(501).send("not logged in to youtube");
    }
});

module.exports = router;