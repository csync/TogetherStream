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
var credentials = require('./private/credentials');
var vcapServices = null;
if (process.env.VCAP_SERVICES) {
    vcapServices = JSON.parse(process.env.VCAP_SERVICES);
} else {
  vcapServices = require('./private/VCAP_SERVICES.json');
}

var appEnv = cfenv.getAppEnv();
if (appEnv.isLocal) {
  console.log('Defaulting to local environment config.');
  appEnv = cfenv.getAppEnv({
      vcap: {
          services: vcapServices
      }
  });
  vcapServices = require('./private/VCAP_SERVICES.json');
}
var nodemailer = require('nodemailer');

var vcapDbService = vcapServices[credentials.app.postgresServiceName] ? vcapServices[credentials.app.postgresServiceName][0] : null;
var dbName =  vcapDbService ? vcapDbService.name : null;
var postgresService = appEnv.getService(dbName);
var pg = require('pg');
var config = parseDBURL(postgresService.credentials.uri);
// max number of clients in the pool
config['max'] = 10;
// how long a client is allowed to remain idle before being closed
config['idleTimeoutMillis'] = 30000;

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
    pool: new pg.Pool(config),
    accessTokenKey: credentials.app.accessTokenKey,
    refreshTokenKey: credentials.app.refreshTokenKey,
    apn: new apn.Provider({
        cert: __dirname + '/private/cert.pem',
        key: __dirname + '/private/key.pem'
    }),
    mail: {
        server: credentials.email.server,
        transporter: nodemailer.createTransport('smtps://' + credentials.email.userName + ':' +
            credentials.email.password + '@' + credentials.email.server)
    }
};

function parseDBURL(dbURL) {
    const url = require('url');

    const params = url.parse(dbURL);
    const auth = params.auth.split(':');

    return {
        user: auth[0],
        password: auth[1],
        host: params.hostname,
        port: params.port,
        database: params.pathname.split('/')[1],
        ssl: true
    };
};

module.exports = appVars;
