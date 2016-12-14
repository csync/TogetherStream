/**
 * Created by danielfirsht on 12/6/16.
 */

var express = require('express');
var authService = require('../auth/auth.service');
var invitesService = require('./invites.service.js');

var router = express.Router();

router.use('/device-token', require('./device-token'));

router.post('', authService.isAuthenticated(), invitesService.processSendingInvites);

router.get('', authService.isAuthenticated(), invitesService.retrieveInvites);

module.exports = router;