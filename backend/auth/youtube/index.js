/**
 * Created by danielfirsht on 12/1/16.
 */
'use strict';

var express = require('express');
var passport = require('passport');
var authService = require('../auth.service');

var router = express.Router();

router.get('/login', passport.authenticate('youtube'));

router.get('/connect', authService.isAuthenticated(), passport.authorize('youtube'));

router.get(
    '/callback',
    passport.authenticate(
        'youtube',
        {
            successRedirect: '/auth/success',
            failureRedirect: '/auth/failure?provider=youtube'
        })
);


module.exports = router;