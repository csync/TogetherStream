/**
 * Created by danielfirsht on 12/2/16.
 */
'use strict';

var FacebookTokenStrategy = require('passport-facebook-token');
var passport = require('passport');
var securityHelper = require('../../security.helper');
var userController = require('../../../user/user.controller');

// exposed function to configure the Facebook Passport Strategy
exports.setup = function (appVars) {
    passport.use(
        new FacebookTokenStrategy({
                clientID: appVars.facebook.clientID,
                clientSecret: appVars.facebook.clientSecret,
                //callbackURL: appVars.facebook.redirectURL,
                passReqToCallback: true
            },
            function (req, accessToken, refreshToken, profile, done) {
                var encryptedAccess = securityHelper.encrypt(accessToken, appVars.accessTokenKey);

                // create the external account object from the fb profile received
                // and the encryption of the access token.
                var facebookAccount = {
                    provider: 'facebook-token',
                    id: profile.id,
                    accessToken: {
                        cipher: encryptedAccess.text,
                        iv: encryptedAccess.iv,
                        tag: encryptedAccess.tag
                    },
                    refreshToken: {}
                };

                userController.processExternalAuthentication(req, facebookAccount)
                    .then(function (user) {
                        done(null, user);
                    }, function (error) {
                        done(error);
                    });
            }
        ));
};