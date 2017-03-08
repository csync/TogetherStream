/**
 * Created by danielfirsht on 3/7/17.
 */

var express = require('express');
var blocksService = require('./blocks.service.js');

var router = express.Router();

router.post('', blocksService.processCreatingBlock);

router.get('', blocksService.retrieveBlocks);


module.exports = router;