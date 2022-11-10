const jwt = require("jsonwebtoken");
const User = require("../models/user.model");
const jsend = require("../utils/jsend");



const JWT = {
    capturer: async function (req, res, next) {
        try {
            const token = req.headers['authorization'].split(' ')[1];
            const payload = jwt.verify(token, process.env.JWT_SECRET);
            const userId = payload['sub'];
            req.userFromJWT = await User.findById(userId);
        } catch (e) {
            console.log("User Session not found: " + e.toString()) ;
        }
        return next();
    },
    sessionNeeded: function(req, res, next) {
        if(!req.userFromJWT) return res.send(jsend.fail("User Session not found.")) ;
        else return next() ;
    } 

};

module.exports = JWT;