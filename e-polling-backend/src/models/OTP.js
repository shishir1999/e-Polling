const moment = require('moment');
const mongoose = require('mongoose');
const config = require('../config/config');
const { sendEmail } = require('../services/email.service');
const { otpMethod, otpPurpose } = require('../utils/constants');
const { randomNumberBetween } = require('../utils/functions');
const User = require('./user.model');

const otpSchema = mongoose.Schema({
  purpose: {
    type: String,
    enum: Object.values(otpPurpose),
    required: true,
  },
  sendingMethod: {
    type: String,
    enum: Object.values(otpMethod),
    required: true,
  },
  // email or phone number here
  receiverAddress: {
    type: String,
    required: true,
  },
  code: {
    type: String,
    required: true,
  },
  expiresAt: {
    type: Date,
    required: true,
    default: Date(),
  },
  isVerified: {
    type: Boolean,
    default: false,
  },
});

otpSchema.statics.getNewCode = async function (purpose) {
  const code = randomNumberBetween(9999, 99999).toString();
  if (await OTP.findOne({ purpose, code })) {
    return await OTP.getNewCode(purpose);
  }
  return code;
};

otpSchema.methods.send = async function () {
  if (this.sendingMethod == otpMethod.sms) throw new Error('SMS is not currently supported');
  if (this.sendingMethod == otpMethod.email) {
    return sendEmail(
      this.receiverAddress,
      `${this.code} is your ${this.purpose} code for ePolling.`,
      `Dear User,

Your ${this.purpose == otpPurpose.voting ? 'voting' : 'password ' + this.purpose} code for ePolling is:

${this.code}

If you have not requested this, please ignore this email.`
    );
  }
};

otpSchema.statics.createNew = async function (options = { receiverAddress, purpose, sendingMethod }) {
  const { receiverAddress, purpose, sendingMethod } = options;
  if (!receiverAddress || !purpose || !sendingMethod) throw new Error('Some params missing');
  let userFilter = {};
  userFilter[sendingMethod == 'email' ? 'email' : 'phone'] = receiverAddress;
  const user = await User.findOne(userFilter);
  if (purpose == otpPurpose.verification && user) throw new Error('Already Taken.');
  if (purpose == otpPurpose.recovery && !user) throw new Error('Not found');
  await OTP.findOne(options).then((otp) => otp && otp.remove());
  return OTP.create({ ...options, code: await OTP.getNewCode(purpose) });
};

otpSchema.statics.verify = async function (code, receiverAddress) {
  const otps = await OTP.find({ code, receiverAddress, expiresAt: { $gt: Date() } });
  if (otps.length != 1) {
    throw new Error('Could not verify');
  }
  otps[0].isVerified = true;
  return otps[0].save();
};

// middlewares
otpSchema.pre('save', function (next) {
  this.set('expiresAt', moment().add(config.otpExpirationMinutes, 'minutes'));
  next();
});

const OTP = mongoose.model('OTP', otpSchema);

module.exports = OTP;
