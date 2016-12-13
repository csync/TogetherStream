var express = require('express');
var auth = require('../auth');
var invites = require('../invites');
var router = express.Router();
var authService = require('../auth/auth.service');

router.use("/auth", auth);

router.use("/invites", authService.isAuthenticated(), invites);

/* GET home page. */
router.get('/', function(req, res, next) {
  res.send("Hello Stormtrooper").end();
});

module.exports = router;
