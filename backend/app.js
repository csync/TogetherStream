/* 
  Copyright 2017 IBM Corporation

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

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
