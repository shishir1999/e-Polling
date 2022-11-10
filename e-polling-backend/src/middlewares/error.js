const mongoose = require('mongoose');
const httpStatus = require('http-status');
const config = require('../config/config');
const logger = require('../config/logger');
const ApiError = require('../utils/ApiError');
const { JsendStatus } = require("../utils/constants");


const errorConverter = (err, req, res, next) => {
  let error = err;
  if (!(error instanceof ApiError)) {
    const statusCode =
      error.statusCode || error instanceof mongoose.Error ? httpStatus.BAD_REQUEST : httpStatus.INTERNAL_SERVER_ERROR;
    const message = error.message || httpStatus[statusCode];
    error = new ApiError(statusCode, message, false, err.stack, false, error instanceof mongoose.Error ? JsendStatus.error : JsendStatus.fail);
  }
  next(error);
};

// eslint-disable-next-line no-unused-vars
const errorHandler = (err, req, res, next) => {
  let { statusCode, message, jsendStatus  } = err;
  if (config.env === 'production' && !err.isOperational) {
    statusCode = httpStatus.INTERNAL_SERVER_ERROR;
    message = httpStatus[httpStatus.INTERNAL_SERVER_ERROR];
  }

  res.locals.errorMessage = err.message;

  // generating "data" field by jsend specification, from message variable
  let data = {} ;
  if(jsendStatus == JsendStatus.fail){
    if(message.length){
      message.split(",").forEach(message => {
        let m = message.match(/"([a-zA-Z0-9]+)"(.*)/);
        if(m != null){
          if(m[1] && m[2]){
            data[m[1]] = (m[1] + m[2]).trim()
          }
        }
      })
    }
  }

  const response = {
    code: statusCode,
    status: jsendStatus == JsendStatus.fail ? "fail" : "error",
    message,
    data,
    ...(config.env === 'development' && { stack: err.stack }),
  };

  if (config.env === 'development') {
    logger.error(err);
  }

  res.status(statusCode).send(response);
};

module.exports = {
  errorConverter,
  errorHandler,
};
