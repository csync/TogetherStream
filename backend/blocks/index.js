//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

var express = require('express');
var blocksService = require('./blocks.service.js');

var router = express.Router();

router.post('', blocksService.processCreatingBlock);

router.get('', blocksService.retrieveBlocks);


module.exports = router;