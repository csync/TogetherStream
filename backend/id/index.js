/**
 * Created by danielfirsht on 1/5/17.
 */

var express = require('express');
var idService = require('./id.service');

var router = express.Router();

router.get('/:userID', idService.retrieveExternalIds);

module.exports = router;