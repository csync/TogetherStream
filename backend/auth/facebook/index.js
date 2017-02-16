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

'use strict';

var express = require('express');
var passport = require('passport');
var authService = require('../auth.service');

var router = express.Router();

router.get('/login', passport.authenticate('facebook'));

router.get('/connect', authService.isAuthenticated(), passport.authorize('facebook'));

router.use('/token', require('./token'));

router.get(
    '/callback', 
    passport.authenticate(
    	'facebook', 
      	{ 
      		successRedirect: '/auth/success',
      		failureRedirect: '/auth/failure?provider=facebook' 
  		})
    );


module.exports = router;