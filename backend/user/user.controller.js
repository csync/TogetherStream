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

module.exports = userController;