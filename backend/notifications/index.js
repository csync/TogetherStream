/**
 * Created by danielfirsht on 12/6/16.
 */

var express = require('express');
var authService = require('../auth/auth.service');
var notificationsService = require('./notifications.service');

var router = express.Router();

router.use('/device-token', require('./device-token'));

router.post('', authService.isAuthenticated(), notificationsService.handleSendingNotifications);

module.exports = router;