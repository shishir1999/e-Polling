const jsend = require("../utils/jsend");

module.exports.isAdmin = (req, res, next) => {
    if (req.userFromJWT && req.userFromJWT.role == 'admin') {
      next();
    } else {
      return res.send(jsend.fail('Admins only'));
    }
}

