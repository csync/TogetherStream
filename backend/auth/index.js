/**
 * Created by danielfirsht on 11/22/16.
 */

var express = require('express');
var appVars = require('../config/appVars');

// Configure Passport
require('./facebook/passport').setup(appVars);

var router = express.Router();

router.use('/facebook', require('./facebook'));

router.get('/success', function (req, res, next) {
   res.send(req.user).end();
});

module.exports = router;