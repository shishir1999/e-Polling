const path = require("path")

module.exports.otpPurpose = {
    verification: 'verification',
    recovery: 'recovery',
    voting: "voting"
}

module.exports.otpMethod = {
    email: 'email',
    sms: 'sms'
}

module.exports.JsendStatus = {
    success: "JSEND_SUCCESS",
    fail: "JSEND_FAIL",
    error: "JSEND_ERROR"
}


module.exports.pathSeparator = path.sep ;

module.exports.votingStatus = {
    hidden: "hidden",
    shown: "shown",
}

module.exports.totalPeriods = 20