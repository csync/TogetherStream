//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

'use strict';

var appVars = require('../config/appVars');
var expressJwt = require('express-jwt');
var jwt = require('jsonwebtoken');
var crypto = require('crypto');

var algorithm   = 'aes-256-gcm';

var validateJwt = expressJwt({secret: appVars.sessionSecret});

/**
 * Provides security methods for the access token.
 * @type {{}}
 */
var securityHelper = {};

securityHelper.validateJwt = function (req, res, next) {
  validateJwt(req, res, next);
};

/**
 * Creates a token with the user id as payload.
 * @param userId
 * @returns {*}
 */
securityHelper.signToken = function(userId) {
    return jwt.sign(
        { id: userId },
        appVars.sessionSecret,
        { expiresIn: "6h" }); // the token will last for 6 hours
};

/**
 * Decrypts the token and verifies its validity.
 * @param token
 * @param ignoreExpiration
 * @returns {*}
 */
securityHelper.decodeToken = function(token, ignoreExpiration) {
    if(typeof(ignoreExpiration) ==='undefined') ignoreExpiration = false;
    return jwt.verify(token, appVars.sessionSecret, { json: true, ignoreExpiration: ignoreExpiration});
};

/**
 * Encrypts the given text with the given key.
 * @param text
 * @param key
 * @returns {{text: *, iv: *, tag: *}}
 */
securityHelper.encrypt = function (text, key) {
    var iv = crypto.randomBytes(16);
    var cipher = crypto.createCipheriv(algorithm, key, iv);
    var encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    var tag = cipher.getAuthTag();

    return {
        text: encrypted,
        iv:  iv,
        tag: tag
    };
};

/**
 * Decrypts the given ciphertext with the given key, iv, and tag.
 * @param encrypted
 * @param key
 * @param iv
 * @param tag
 * @returns {*}
 */
securityHelper.decrypt = function(encrypted, key, iv, tag) {
    var decipher = crypto.createDecipheriv(algorithm, key, iv);
    decipher.setAuthTag(tag);
    var decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');

    return decrypted;
};

module.exports = securityHelper;