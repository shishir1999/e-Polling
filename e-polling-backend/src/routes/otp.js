const express = require('express');
const { body } = require('express-validator');
const handleValidationErrors = require('../middlewares/handleValidationErrors');
const OTP = require('../models/OTP');
const User = require('../models/user.model');
const catchAsync = require('../utils/catchAsync');
const { otpPurpose, otpMethod } = require('../utils/constants');
const jsend = require('../utils/jsend');

const router = express.Router();

//sending verification email
router.post(
  '/send-verification-email',
  [body('email').isEmail()],
  handleValidationErrors(),
  catchAsync(async function (req, res) {
    try {
      const otp = await OTP.createNew({
        receiverAddress: req.body.email,
        purpose: otpPurpose.verification,
        sendingMethod: otpMethod.email,
      });
      await otp.send();
      return res.send(jsend.success({}));
    } catch (e) {
      return res.send(jsend.fail('Something went wrong', { email: e.toString() }));
    }
  })
);

// submitting otp code
router.post(
  '/submit',
  [body('code').exists(), body('receiverAddress').exists()],
  handleValidationErrors(),
  catchAsync(async function (req, res) {
    try {
      const otp = await OTP.verify(req.body.code, req.body.receiverAddress);
      return res.send(jsend.success({ otpId: otp._id }));
    } catch (e) {
      return res.send(jsend.fail(e.toString()));
    }
  })
);

// send password reset email
router.post(
  '/send-recovery-email',
  [body('email').isEmail()],
  handleValidationErrors(),
  catchAsync(async function (req, res) {
    try {
      const otp = await OTP.createNew({
        receiverAddress: req.body.email,
        purpose: otpPurpose.recovery,
        sendingMethod: otpMethod.email,
      });
      await otp.send();
      return res.send(jsend.success({}));
    } catch (e) {
      return res.send(jsend.fail('Something went wrong', { email: e.toString() }));
    }
  })
);

// reset password
router.post(
  '/reset-password',
  [body('otpId').exists(), body('password').exists().isLength({ min: 8 })],
  handleValidationErrors(),
  catchAsync(async function (req, res) {
    try {
      const otp = await OTP.findById(req.body.otpId);
      if (!otp || !otp.isVerified) throw new Error('Invalid OTP');
      if (otp.purpose != otpPurpose.recovery) throw new Error('Invalid OTP');
      let userFilter = {};

      userFilter[otp.sendingMethod == 'email' ? 'email' : 'phone'] = otp.receiverAddress;

      const user = await User.findOne(userFilter);
      if (!user) throw new Error('Something went wrong');

      if (!req.body.password.match(/\d/) || !req.body.password.match(/[a-zA-Z]/)) {
        return res.send(jsend.fail('', { password: 'Must contain at least one letter and one number' }));
      }

      user.password = req.body.password;

      await user.save();

      await otp.remove();

      return res.send(jsend.success({}));
    } catch (e) {
      return res.send(jsend.fail('Something went wrong', { otpId: e.toString() }));
    }
  })
);

//sending voting verification email
router.post(
  '/send-voting-email',
  [body('email').isEmail()],
  handleValidationErrors(),
  catchAsync(async function (req, res) {
    try {
      const otp = await OTP.createNew({
        receiverAddress: req.body.email,
        purpose: otpPurpose.voting,
        sendingMethod: otpMethod.email,
      });
      await otp.send();
      return res.send(jsend.success({}));
    } catch (e) {
      return res.send(jsend.fail('Something went wrong', { email: e.toString() }));
    }
  })
);

module.exports = router;
