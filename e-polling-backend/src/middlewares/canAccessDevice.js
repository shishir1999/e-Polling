const jsend = require("../utils/jsend");

module.exports.canAccessDevice = (req, res, next) => {
  if (!req.device) {
    return res.send(jsend.fail('Device not set'));
  }
  if(!req.userFromJWT){
    return res.send(jsend.fail('Login Needed'));
  }
  if  (  req.userFromJWT.role == 'admin') {
    next();
    return;
  } else {
    if (req.device.users.indexOf(req.userFromJWT._id) != -1) {
      next();
      return;
    } else {
      return res.send(jsend.fail('You are not allowed to access this device'));
    }
  }
};

