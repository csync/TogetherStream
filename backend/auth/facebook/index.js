/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
 'use strict';

var express = require('express');
var passport = require('passport');
//var auth = require('../auth.service');

var router = express.Router();

router.get('/login', passport.authenticate('facebook'));

router.get('/connect', passport.authorize('facebook'));

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