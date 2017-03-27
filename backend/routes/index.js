//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

var express = require('express');
var auth = require('../auth');
var blocks = require('../blocks');
var invites = require('../invites');
var router = express.Router();
var authService = require('../auth/auth.service');
var favicon = require('serve-favicon');

// Constants
var sixHours = 21600;
var standardOptions = {
  maxAge: sixHours,
  root: __dirname
};

router.use("/auth", auth);

router.use("/blocks", authService.isAuthenticated(), blocks);

router.use("/invites", authService.isAuthenticated(), invites);

// Loading assets
router.use(express.static('./public'));

router.use(favicon('./public/favicon.ico'));

/* GET home page. */
router.get('/', function(req, res, next) {
  res.set({
    "Cache-Control": "public, max-age=21600"
  });
  res.sendFile('index.html', standardOptions, function(err) {
    if (err) {
      console.log(err);
      res.status(err.status).send(err);
    }
  });
});

module.exports = router;
