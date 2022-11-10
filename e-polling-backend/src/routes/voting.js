const express = require('express');
const { body, param } = require('express-validator');
const handleValidationErrors = require('../middlewares/handleValidationErrors');
const catchAsync = require('../utils/catchAsync');
const jsend = require('../utils/jsend');
const router = express.Router();
const Voting = require('./../models/voting');
const moment = require('moment');

router.get('/', async function (req, res) {
  try {
    const filter = req.userFromJWT && req.userFromJWT.role === 'admin' ? {} : { status: 'shown', to: { $gte: moment().toDate() } };

    res.json({
      status: 'success',
      data: await Voting.find(filter).then((v) => Promise.all(v.map((vote) => vote.formatted(req)))),
    });
  } catch (e) {
    res.json({ status: 'error', message: e.message });
  }
});
  
router.get('/results', async function (req, res) {
  try {
    const filter = { status: 'shown', to: { $lte: moment().toDate() } };

    res.json({
      status: 'success',
      data: await Voting.find(filter).then((v) => Promise.all(v.map((vote) => vote.formatted(req)))),
    });
  } catch (e) {
    res.json({ status: 'error', message: e.message });
  }
});

// add new voting
router.post(
  '/',
  function (req, res, next) {
    if (req.userFromJWT && req.userFromJWT.role === 'admin') {
      next();
    } else {
      res.status(401).json(jsend.fail('Admins only'));
    }
  },
  [
    body('title').exists().withMessage('Title is required'),
    body('description').optional(),
    body('from').exists(),
    body('to').exists(),
  ],
  handleValidationErrors(),
  catchAsync(async function (req, res) {
    const voting = await Voting.create({
      title: req.body.title,
      description: req.body.description,
      from: moment(req.body.from).toDate(),
      to: moment(req.body.to).toDate(),
    });
    res.send(jsend.success(await voting.formatted(req)));
  })
);

const singleVotingRouter = express.Router();

router.use(
  '/:votingId',
  [
    param('votingId')
      .exists()
      .withMessage('Voting ID is required')
      .custom(async function (votingId, { req }) {
        req.voting = await Voting.findById(votingId);
        if (!req.voting) throw new Error('Voting not found.');
        else return true;
      }),
  ],
  handleValidationErrors(),
  singleVotingRouter
);

singleVotingRouter.get('/', async function (req, res) {
  res.send(jsend.success(await req.voting.formatted(req)));
});

// edit voting details
singleVotingRouter.put(
  '/',
  function (req, res, next) {
    if (req.userFromJWT && req.userFromJWT.role === 'admin') {
      next();
    } else {
      res.status(401).json(jsend.fail('Admins only'));
    }
  },
  [
    body('title').exists().withMessage('Title is required'),
    body('description').optional(),
    body('from').exists(),
    body('to').exists(),
    body('status').exists().withMessage('Status is required'),
  ],
  handleValidationErrors(),
  catchAsync(async function (req, res) {
    req.voting.title = req.body.title;
    req.voting.description = req.body.description;
    req.voting.from = moment(req.body.from).toDate();
    req.voting.to = moment(req.body.to).toDate();
    req.voting.status = req.body.status;
    await req.voting.save();
    res.send(jsend.success(await req.voting.formatted(req)));
  })
);

// delete voting
singleVotingRouter.delete(
  '/',
  function (req, res, next) {
    if (req.userFromJWT && req.userFromJWT.role === 'admin') {
      next();
    } else {
      res.status(401).json(jsend.fail('Admins only'));
    }
  },
  catchAsync(async function (req, res) {
    await req.voting.remove();
    res.send(jsend.success({}));
  })
);

singleVotingRouter.use('/candidates', require('./candidate'));

module.exports = router;
