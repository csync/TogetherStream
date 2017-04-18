//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

'use strict';

var contentCleaner = require('./contentCleaner');
var cron = require('node-cron');
cron.schedule('0 2 * * *', contentCleaner.clean);

var bot = require('./bot');
bot.run();