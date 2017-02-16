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

var apn = require("apn");
var cfenv = require("cfenv");
var vcapServices = require('./private/VCAP_SERVICES.json')
var vcapDbService = vcapServices["compose-for-postgresql"] ? vcapServices["compose-for-postgresql"][0] : null
var appEnv = cfenv.getAppEnv({
    vcap: {
        services: vcapServices
    }
});
var dbName =  vcapDbService ? vcapDbService.name : null
var postgresService = appEnv.getService(dbName);
var credentials = require('./private/credentials');

var appVars = {
    port: appEnv.port,
    bind: appEnv.bind,
    sessionSecret: credentials.sessionSecret,
    facebook: {
        clientID: credentials.facebook.appID,
        clientSecret: credentials.facebook.secret,
        redirectURL: appEnv.url + "/auth/facebook/callback"
    },
    google: {
        clientID: credentials.google.clientID,
        clientSecret: credentials.google.clientSecret,
        redirectURL: appEnv.url + "/auth/youtube/callback"
    },
    postgres: postgresService.credentials,
    accessTokenKey: credentials.app.accessTokenKey,
    refreshTokenKey: credentials.app.refreshTokenKey,
    apn: new apn.Provider({
        cert: __dirname + '/private/cert.pem',
        key: __dirname + '/private/key.pem'
    })
};

module.exports = appVars;