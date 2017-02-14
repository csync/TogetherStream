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