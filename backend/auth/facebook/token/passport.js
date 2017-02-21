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