var express = require('express');
var auth = require('../auth');
var router = express.Router();

router.use("/auth", auth);

/* GET home page. */
router.get('/', function(req, res, next) {
  res.send("Hello Stormtrooper").end();
});

module.exports = router;
