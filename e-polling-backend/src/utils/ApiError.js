const { JsendStatus } = require("./constants");



class ApiError extends Error {
  constructor(statusCode, message, isOperational = true, stack = '', jsendStatus = JsendStatus.fail) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.jsendStatus = jsendStatus;
    if (stack) {
      this.stack = stack;
    } else {
      Error.captureStackTrace(this, this.constructor);
    }
  }
}

module.exports = ApiError;
