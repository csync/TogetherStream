//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

require('newrelic'); // setup new relic performance monitoring
'use strict';

var agent = require('bluemix-autoscaling-agent');
var express = require('express');
var path = require('path');

var routes = require('./routes/index');
var appVars = require('./config/appVars');

var app = express();

// setup application
require('./config/index')(app);

app.use('/', routes);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});


app.listen(appVars.port, appVars.bind, function () {
    console.log('Server listening on ' + appVars.port)
});
