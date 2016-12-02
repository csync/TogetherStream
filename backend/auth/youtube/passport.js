/**
 * Created by danielfirsht on 12/1/16.
 */
var passport = require('passport');
var YoutubeV3Strategy = require('passport-youtube-v3').Strategy;
var securityHelper = require('../security.helper');
var userController = require('../../user/user.controller');

// exposed function to configure the Facebook Passport Strategy
exports.setup = function (appVars) {
    passport.use(new YoutubeV3Strategy({
            clientID: appVars.google.clientID,
            clientSecret: appVars.google.clientSecret,
            callbackURL: appVars.google.redirectURL,
            passReqToCallback: true,
            scope: ['https://www.googleapis.com/auth/youtube.readonly', "https://www.googleapis.com/auth/plus.login"]
        },
        function (req, accessToken, refreshToken, profile, done) {
            var encryptedAccess = securityHelper.encrypt(accessToken, appVars.accessTokenKey);
            var encryptedRefresh = securityHelper.encrypt(refreshToken, appVars.refreshTokenKey);

            // create the external account object from the yt profile received
            // and the encryption of the access token.
            var googleAccount = {
                provider: 'youtube',
                id: profile.id,
                accessToken: {
                    cipher: encryptedAccess.text,
                    iv: encryptedAccess.iv,
                    tag: encryptedAccess.tag
                },
                refreshToken: {
                    cipher: encryptedRefresh.text,
                    iv: encryptedRefresh.iv,
                    tag: encryptedRefresh.tag
                }
            };

            userController.processExternalAuthentication(req, googleAccount)
                .then(function (user) {
                    done(null, user);
                });
        }
    ));
};