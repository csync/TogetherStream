var express = require('express');
var auth = require('../auth');
var notifications = require('../notifications');
var router = express.Router();
var authService = require('../auth/auth.service');

router.use("/auth", auth);

router.use("/notifications", authService.isAuthenticated(), notifications);

/* GET home page. */
router.get('/', function(req, res, next) {
  res.send("Hello Stormtrooper").end();
});

module.exports = router;
