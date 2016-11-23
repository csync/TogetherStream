/**
 * Created by danielfirsht on 11/22/16.
 */

var authService = {}

authService.isAuthenticated = function (req, res, next) {
    // if(req.user == null) {
    //    res.status(401).send("Not authenticated");
    // }
    next();
};

module.exports = authService;