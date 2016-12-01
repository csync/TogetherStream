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
            scope: ['https://www.googleapis.com/auth/youtube.readonly']
        },
        function (req, accessToken, refreshToken, profile, done) {
            var encrypted = securityHelper.encrypt(accessToken, appVars.accessTokenKey);

            // create the external account object from the fb profile received
            // and the encryption of the access token.
            var googleAccount = {
                provider: 'youtube',
                id: profile.id,
                accessToken: encrypted.text,
                iv: encrypted.iv,
                tag: encrypted.tag
            };

            userController.processExternalAuthentication(req, googleAccount)
                .then(function (user) {
                    done(null, user);
                });
        }
    ));
};