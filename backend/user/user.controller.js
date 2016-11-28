/**
 * Created by danielfirsht on 11/22/16.
 */

var userController = {};

var userDB = [];

userController.registerUser = function(user) {
    return userController.saveUser(user);
};

userController.saveUser = function (user) {
    return new Promise(function (resolve, reject) {
        var position = userDB.map(function (e) {
            return e.id
        }).indexOf(user.id);
        if(position != -1) {
            userDB[position] = user
        }
        else {
            userDB.push(user);
        }
        resolve(user);
    });
};

userController.saveExternalAccount = function(userId, externalAccount) {
    return new Promise(function (resolve, reject) {
        var position = userDB.map(function (e) {
            return e.id
        }).indexOf(user.id);
        if(position != -1) {
            userDB[position].externalAccount = externalAccount
        }
        else {
            userDB.push({id: userId, externalAccount: externalAccount});
        }
        resolve();
    });
};

userController.getUserByID = function (id) {
  return new Promise(function (resolve, reject) {
      var position = userDB.map(function (e) {
          return e.id
      }).indexOf(id);
      if(position != -1) {
          resolve(userDB[position]);
      }
      else {
          reject("user not found");
      }
  })
};

userController.processExternalAuthentication = function (req, externalAccount) {
    return new Promise(function (resolve, reject) {
        var position = userDB.map(function (e) {
            return e.id
        }).indexOf(externalAccount.id);
        if(position != -1) {
            var user = userDB[position];
            if(user.externalAccount.provider == externalAccount.provider) {
                // user already has the external account just login
                resolve(user)
            }
            else {
                userController.saveExternalAccount(externalAccount.id, externalAccount)
                    .then(function () {
                        resolve(user)
                    })
            }
        }
        else {
            userController.registerUser({id: externalAccount.id, externalAccount: externalAccount})
                .then(function (user) {
                    resolve(user);
                })
        }
    })
};

module.exports = userController;