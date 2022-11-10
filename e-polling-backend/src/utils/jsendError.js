const { JsendStatus } = require("../helpers/constants");
const ApiError = require("./ApiError");

class jsendError extends ApiError {
  constructor(errorObject,jsendStatus = JsendStatus.fail, customMessage="") {
super(555, (customMessage.length > 0 )? customMessage : errorObject.toString(), true, errorObject.stack, jsendStatus) ;
  }
}

module.exports = jsendError;
