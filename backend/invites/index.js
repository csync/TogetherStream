//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

var express = require('express');
var authService = require('../auth/auth.service');
var invitesService = require('./invites.service.js');

var router = express.Router();

router.use('/device-token', require('./device-token'));

router.post('', authService.isAuthenticated(), invitesService.processSendingInvites);

router.get('', authService.isAuthenticated(), invitesService.retrieveInvites);

router.delete('', authService.isAuthenticated(), invitesService.deleteInvites);

module.exports = router;