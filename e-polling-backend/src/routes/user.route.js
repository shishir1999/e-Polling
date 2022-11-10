const express = require('express');
const auth = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const userValidation = require('../validations/user.validation');
const userController = require('../controllers/user.controller');
const catchAsync = require('../utils/catchAsync');
const jsend = require('../utils/jsend');
const jwt = require('./../middlewares/jwt');
const Vote = require('../models/vote');
const Voting = require('../models/voting');
const Candidate = require('../models/candidate');

const router = express.Router();

const meRouter = express.Router();

router.use('/me', jwt.sessionNeeded, meRouter);

meRouter.get(
  '/',
  catchAsync(async function (req, res) {
    return res.send(jsend.success({ user: req.userFromJWT }));
  })
);

meRouter.get(
  '/votings',
  catchAsync(async function (req, res) {
    const votedCandidates = (await Vote.find({ user: req.userFromJWT._id }, 'candidate')).map((c) => c.candidate);

    const votings = (await Candidate.find({ _id: { $in: votedCandidates } }, 'voting')).map((v) => v.voting);

    const result = await Voting.find({ _id: { $in: votings } }).then((v) =>
      Promise.all(v.map((vote) => vote.formatted(req)))
    );

    res.send(jsend.success({ votings: result }));
  })
);

meRouter.get(
  "/votedCandidates",
  catchAsync(async function (req, res) {

    const votedCandidates = (await Vote.find({ user: req.userFromJWT._id }, 'candidate')).map((c) => c.candidate);

    res.send(jsend.success({ votedCandidates }));
  })) ;

router
  .route('/')
  .post(auth('manageUsers'), validate(userValidation.createUser), userController.createUser)
  .get(auth('getUsers'), validate(userValidation.getUsers), userController.getUsers);

router
  .route('/:userId')
  .get(auth('getUsers'), validate(userValidation.getUser), userController.getUser)
  .patch(auth('manageUsers'), validate(userValidation.updateUser), userController.updateUser)
  .delete(auth('manageUsers'), validate(userValidation.deleteUser), userController.deleteUser);

module.exports = router;
