//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-non-ios
//

'use strict';
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var passport = require('passport');
var cookieSession = require('cookie-session');

var appVars = require('./appVars');
var userController = require('../user/user.controller');

module.exports = function (app) {
    // uncomment after placing your favicon in /public
    //app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
    app.use(logger('dev'));
    app.use(bodyParser.json());
    app.use(bodyParser.urlencoded({ extended: false }));
    app.use(cookieParser());
    app.use(cookieSession({
        secret: appVars.sessionSecret,
        resave: "false",
        saveUninitialized: "false",
        maxAge: 1000*60*60
    }));
    app.use(passport.initialize());
    app.use(passport.session());

    passport.serializeUser(function(user, done) {
        done(null, user.id);
    });

    passport.deserializeUser(function(id, done) {
        userController.getUserByID(id).then(function (user) {
            done(null,user);
        }, function (error) {
            done(error);
        });
    });
};