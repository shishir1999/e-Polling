const httpStatus = require('http-status');
const { User } = require('../models');
const OTP = require('../models/OTP');
const ApiError = require('../utils/ApiError');
const { otpMethod } = require('../utils/constants');


const createUser = async (userBody) => {
  const otp = await OTP.findById(userBody.otp) ;
  if(!otp || !otp.isVerified) throw new Error("OTP invalid") ;
  let rawUser = userBody ;

  if(otp.sendingMethod == otpMethod.email){
    if (await User.isEmailTaken(otp.receiverAddress)) {
      throw new ApiError(httpStatus.BAD_REQUEST, 'Email already taken');
    }
    rawUser['email'] = otp.receiverAddress
    rawUser['isEmailVerified'] = true
  }else{
    if (await User.isPhoneTaken(otp.receiverAddress)) {
      throw new ApiError(httpStatus.BAD_REQUEST, 'Phone already taken');
    }
    rawUser['phone'] = otp.receiverAddress
  }

  return User.create(rawUser);
};

const queryUsers = async (filter, options) => {
  const users = await User.paginate(filter, options);
  return users;
};

const getUserById = async (id) => {
  return User.findById(id);
};

const getUserByEmail = async (email) => {
  return User.findOne({ email });
};

const updateUserById = async (userId, updateBody) => {
  const user = await getUserById(userId);
  if (!user) {
    throw new ApiError(httpStatus.NOT_FOUND, 'User not found');
  }
  if (updateBody.email && (await User.isEmailTaken(updateBody.email, userId))) {
    throw new ApiError(httpStatus.BAD_REQUEST, 'Email already taken');
  }
  Object.assign(user, updateBody);
  await user.save();
  return user;
};

const deleteUserById = async (userId) => {
  const user = await getUserById(userId);
  if (!user) {
    throw new ApiError(httpStatus.NOT_FOUND, 'User not found');
  }
  await user.remove();
  return user;
};

module.exports = {
  createUser,
  queryUsers,
  getUserById,
  getUserByEmail,
  updateUserById,
  deleteUserById,
};
