/**
 * Created by danielfirsht on 11/22/16.
 */

var pg = require('pg');
var appVars = require('../config/appVars');

var userController = {};

userController.registerUser = function(user) {
    return userController.saveUser(user);
};

userController.saveUser = function (user) {
    return new Promise(function (resolve, reject) {
        var client = new pg.Client(appVars.postgres.uri);
        client.connect();
        // Update users if exists, otherwise insert it
        client.query("UPDATE users SET id=$1 WHERE id = $2;", [user.id, user.id]);
        client.query("INSERT INTO users (id) SELECT $1 WHERE NOT EXISTS (SELECT 1 FROM users WHERE id = $2);",  [user.id, user.id],
            function (err, result) {
                if (err) reject(err);

                resolve(user);

                client.end();
            }
        );
    });
};

userController.saveExternalAccount = function(userId, externalAccount) {
    return new Promise(function (resolve, reject) {
        var client = new pg.Client(appVars.postgres.uri);
        client.connect();
        // Update external account if exists with that provider, otherwise insert it
        client.query("UPDATE external_auth SET id=$1, access_token=$2 WHERE user_id=$3 AND provider=$4;", [externalAccount.id, externalAccount.accessToken, userId, externalAccount.provider]);
        client.query("INSERT INTO external_auth (id, access_token, provider, user_id) SELECT $1, $2, $3, $4"
            + "WHERE NOT EXISTS (SELECT 1 FROM external_auth WHERE user_id=$4 AND provider=$3);",
            [externalAccount.id, externalAccount.accessToken, externalAccount.provider, userId],
            function (err, result) {
                if (err) reject(err);

                resolve();

                client.end();
            }
        );
    });
};

userController.getUserByID = function (id) {
  return new Promise(function (resolve, reject) {
      var client = new pg.Client(appVars.postgres.uri);
      client.connect();
      // Get user and external accounts
      client.query("SELECT id FROM users WHERE id=$1", [id],
          function (err, result) {
              if (err) reject(err);
              if (result.rowCount < 1) reject("user not found");
              var user = {id: result.rows[0].id};

              client.query("SELECT provider, access_token FROM external_auth WHERE user_id=$1", [id],
                  function (err, result) {
                      if (err) reject(err);
                      user.externalAccounts = result.rows;
                      resolve(user);

                      client.end();
                  });
          }
      );
  })
};

userController.processExternalAuthentication = function (req, externalAccount) {
    return new Promise(function (resolve, reject) {
        var id = externalAccount.id;
        userController.getUserByID(id)
            .then(function (user) {
                if(user.externalAccounts.filter(function (e) {
                        return e.provider == externalAccount.provider
                    }).count > 0) {
                    // user already has the external account just login
                    resolve(user)
                }
                else {
                    userController.saveExternalAccount(externalAccount.id, externalAccount)
                        .then(function () {
                            resolve(user)
                        })
                }
            }, function (error) {
                if(error == "user not found")
                    userController.registerUser({id: externalAccount.id})
                        .then(function (user) {
                            userController.saveExternalAccount(user.id, externalAccount)
                                .then(function () {
                                    resolve(user);
                                });
                        })
            });
    })
};

module.exports = userController;