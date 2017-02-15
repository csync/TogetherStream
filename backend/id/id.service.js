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

var appVars = require('../config/appVars');
var pg = require('pg');
var userController = require('../user/user.controller')

var idService = {};

idService.retrieveExternalIds = function (req, res) {
    userController.getUserByID(req.params['userID'])
        .then(function (user) {
            if(user == null) {
                res.sendStatus(204);
                return
            }
            var ids = {};
            for(var i = 0; i < user.externalAccounts.length; ++i) {
                var account = user.externalAccounts[i];
                ids[account.provider] = account.id;
            }
            res.send(ids);
        }, function (error) {
            res.sendStatus(401);
        })
};

module.exports = idService;