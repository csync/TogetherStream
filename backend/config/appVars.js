/**
 * Created by danielfirsht on 11/22/16.
 */
var cfenv = require("cfenv");
var appEnv = cfenv.getAppEnv({
    vcap: {
        services: require('./VCAP_SERVICES.json')
    }
});
var postgresService = appEnv.getService('Compose for PostgreSQL-5h');
var credentials = require('./credentials');

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
    refreshTokenKey: credentials.app.refreshTokenKey
};

module.exports = appVars;