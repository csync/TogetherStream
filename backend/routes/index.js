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
var auth = require('../auth');
var blocks = require('../blocks');
var invites = require('../invites');
var router = express.Router();
var authService = require('../auth/auth.service');
var favicon = require('serve-favicon');

// Constants
var sixHours = 21600;
var standardOptions = {
  maxAge: sixHours,
  root: __dirname
};

router.use("/auth", auth);

router.use("/blocks", authService.isAuthenticated(), blocks);

router.use("/invites", authService.isAuthenticated(), invites);

// Loading assets
router.use(express.static('./public', {
  maxAge: sixHours
}));

router.use(favicon('./public/favicon.ico'));

/* GET home page. */
router.get('/', function(req, res, next) {
  res.set({
    "Cache-Control": "public, max-age=21600"
  });
  res.sendFile('index.html', standardOptions, function(err) {
    if (err) {
      console.log(err);
      res.status(err.status).send(err);
    }
  });
});

module.exports = router;
