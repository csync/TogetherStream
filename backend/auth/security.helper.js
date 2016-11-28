/**
 * Created by danielfirsht on 11/28/16.
 */
'use strict';

var appVars = require('../config/appVars');
var expressJwt = require('express-jwt');
var jwt = require('jsonwebtoken');

var validateJwt = expressJwt({secret: appVars.sessionSecret});

var securityHelper = {};

securityHelper.validateJwt = function (req, res, next) {
  validateJwt(req, res, next);
};

// Creates a token with the user id as payload
securityHelper.signToken = function(userId) {
    return jwt.sign(
        { id: userId },
        appVars.sessionSecret,
        { expiresIn: "1h" }); // the token will last for an hour
};

securityHelper.decodeToken = function(token) {
    return jwt.decode(token, { json: true});
};

module.exports = securityHelper;