/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var FacebookStrategy = require('passport-facebook').Strategy;
var passport = require('passport');
// var secHelper		     = require('../../../../../Downloads/MILAuth-master/nodeJS/auth/security.helper.js');
var userController = require('../../user/user.controller');

// exposed function to configure the Facebook Passport Strategy
exports.setup = function (appVars) {
    passport.use(
        new FacebookStrategy({
                clientID: appVars.facebook.clientID,
                clientSecret: appVars.facebook.clientSecret,
                callbackURL: appVars.facebook.redirectURL,
                passReqToCallback: true
            },
            function (req, accessToken, refreshToken, profile, done) {
                var userName = profile.displayName.replace(/\s/g, ''); // remove spaces

                var facebookAccount = {provider: 'facebook', id: profile.id, profile: profile, accessToken: accessToken};
                userController.processExternalAuthentication(req, facebookAccount)
                    .then(function (user) {
                        done(null, user);
                    });
                // TODO: what's below here
                // var encryption = secHelper.encrypt(accessToken);
                //
                // // create the external account object from the fb profile received
                // // and the encryption of the access token.
                // var facebookAccount = {
                //     provider: 'facebook',
                //     token: encryption.text,
                //     encIv: encryption.iv,
                //     enctag: encryption.tag,
                //     extId: profile.id,
                //     displayName: profile.displayName
                // };

                // userController.processExternalAuth(
                //     req,
                //     userName,
                //     facebookAccount)
                //     .then(function (user) {
                //         done(null, user);
                //     });
            }
        ));
};