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

var express = require('express');
var appVars = require('../config/appVars');
var authService = require('./auth.service');

// Configure Passport
require('./facebook/passport').setup(appVars);
require('./facebook/token/passport').setup(appVars);
require('./youtube/passport').setup(appVars);

var router = express.Router();

router.use('/facebook', require('./facebook'));
router.use('/youtube', require('./youtube'));

router.get('/success', authService.handleLoginSuccess);

router.get('/failure', function (req, res, next) {
    res.send("failed to authenticate");
});

router.get('/logout', authService.logout);

router.get('/refresh', authService.refresh);

router.get('/me', authService.isAuthenticated(), function (req, res, next) {
   res.json(req.user);
});

module.exports = router;