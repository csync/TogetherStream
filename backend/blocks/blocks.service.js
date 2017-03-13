//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

var userController = require('../user/user.controller');
var appVars = require('../config/appVars');

var blocksService = {};

blocksService.processCreatingBlock = function (req, res) {
    var blockee = req.body["blockee"];
    userController.getUserAccountByExternalAccount({id: blockee, provider: 'facebook-token'})
        .then(function (blockeeAccount) {
            createBlock(req.user, blockeeAccount)
        });

    res.sendStatus(200);
};

blocksService.retrieveBlocks = function (req, res) {
    retrieveBlocks(req.user)
        .then(function (blocks) {
            res.json(blocks)
        }, function (error) {
            res.status(500).send(error);
        })
};

var createBlock = function (blocker, blockee) {
    return new Promise(function (resolve, reject) {
        var pool = appVars.pool;
        pool.connect(function (err, client, done) {
            if (err) {
                return console.error('error fetching client from pool', err);
            }
            client.query("INSERT INTO blocks (blocker, blockee) SELECT $1, $2", [blocker.id, blockee.id],
                function (err, result) {
                    done(err);
                    if (err) {
                        reject(err);
                    }
                    else {
                        resolve();
                    }
                }
            );
        });
    })
};

var retrieveBlocks = function (user) {
    return new Promise(function (resolve, reject) {
        var pool = appVars.pool;
        pool.connect(function (err, client, done) {
            if (err) {
                return console.error('error fetching client from pool', err);
            }
            client.query("SELECT external_auth.* FROM blocks " +
                "INNER JOIN external_auth ON CASE WHEN blocks.blocker=$1 THEN blocks.blockee WHEN blocks.blockee=$1 THEN blocks.blocker END = external_auth.user_id " +
                "WHERE ((blocks.blocker=$1 OR blocks.blockee=$1) AND external_auth.user_id = CASE WHEN blocks.blocker=$1 THEN blocks.blockee WHEN blocks.blockee=$1 THEN blocks.blocker END)", [user.id],
                function (err, result) {
                    done(err);
                    if (err) {
                        reject(err);
                    }
                    else {
                        var results = result.rows;
                        if (results.length == 0) {
                            resolve(results);
                        }
                        else {
                            // flatten external accounts
                            var blockedUsers = {};

                            for (var i = 0; i < results.length; i++) {
                                var userId = results[i].user_id;
                                if (blockedUsers[userId] == null) {
                                    blockedUsers[userId] = { id: userId};
                                    blockedUsers[userId].external_accounts = {};
                                    blockedUsers[userId].external_accounts[results[i].provider] = results[i].id;
                                }
                                else {
                                    blockedUsers[userId].external_accounts[results[i].provider] = results[i].id;
                                }
                            }
                            var flattenedUsers = [];
                            for (var invite in blockedUsers) {
                                flattenedUsers.push(blockedUsers[invite])
                            }
                            resolve(flattenedUsers);
                        }
                    }
                }
            );
        });
    })
};

module.exports = blocksService;