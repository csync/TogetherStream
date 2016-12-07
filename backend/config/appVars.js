/**
 * Created by danielfirsht on 11/22/16.
 */
var apn = require("apn");
var cfenv = require("cfenv");
var appEnv = cfenv.getAppEnv({
    vcap: {
        services: require('./private/VCAP_SERVICES.json')
    }
});
var postgresService = appEnv.getService('Compose for PostgreSQL-5h');
var credentials = require('./private/credentials');

var appVars = {
    port: appEnv.port,
    bind: appEnv.bind,
    sessionSecret: "meow meow",
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