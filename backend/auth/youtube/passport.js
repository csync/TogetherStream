/* 
  Copyright 2017 IBM Corporation

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
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
                }, function (error) {
                    done(error);
                });
        }
    ));
};