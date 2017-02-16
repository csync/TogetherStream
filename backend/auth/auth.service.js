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
var securityHelper = require('./security.helper');
var compose = require('composable-middleware');
var userController = require('../user/user.controller');

var authService = {};

authService.isAuthenticated = function (req, res, next) {
    return compose()
        .use(function (req, res, next) {
            if(req.user) {
                // already authenticated
                next()
            }
            else {
                // allow access_token to be passed through query parameter as well
                if (req.query && req.query.hasOwnProperty('access_token')) {
                    req.headers.authorization = 'Bearer ' + req.query.access_token;
                }

                securityHelper.validateJwt(req, res, next);
            }
        })
        .use(function(err, req, res, next) {
            if (err.name === 'UnauthorizedError') {
                res.status(401).send('invalid token');
            } else {
                next();
            }
        })
        .use(function(req, res, next) {
            userController.getUserByID(req.user.id).then(function (user) {
                req.user = user;
                next();
            }, function (error) {
                res.status(503).send(error).end();
            })
        });
};

authService.refresh = function(req, res) {
    // allow for access token to be on present as a URL param
    if(req.query && req.query.hasOwnProperty('access_token')) {
        req.headers.authorization = 'Bearer ' + req.query.access_token;
    }

    if(req.headers.authorization) {
        // get the user id from the invalid token
        var token = req.headers.authorization.split(' ')[1];
        var tokenPayload = securityHelper.decodeToken(token, true);
        var userId = tokenPayload.id;

        var newToken = securityHelper.signToken(userId);
        res.json({ "access_token": newToken});
    } else {
        res.status(400).send('Bearer token is required');
    }
};

authService.logout = function (req, res) {
    req.logout();
    res.redirect('/');
};

authService.handleLoginSuccess = function(req, res) {
    // get the user id from the user attribute appended to the request by passport
    // or from the query param
    if(req.user || req.query.id) {
        var userId = req.user ? req.user.id : req.query.id;
        var accessToken = securityHelper.signToken(userId);
        res.redirect('/?access_token=' + accessToken);
        // if not user id is found then the auth was actually a failure
    } else {
        res.redirect('/auth/failure?provider=' + req.query.provider);
    }
};


module.exports = authService;