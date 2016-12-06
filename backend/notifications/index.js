/**
 * Created by danielfirsht on 12/6/16.
 */

var express = require('express');

var router = express.Router();

router.use('/device-token', require('./device-token'));

module.exports = router;