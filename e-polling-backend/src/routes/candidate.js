const express = require('express');
const handleValidationErrors = require('../middlewares/handleValidationErrors');
const catchAsync = require('../utils/catchAsync');
const jsend = require('../utils/jsend');
const Candidate = require('./../models/candidate');
const { body, param } = require('express-validator');
const multer = require('multer');
const OTP = require('../models/OTP');
const { User } = require('../models');
const Vote = require('../models/vote');

const router = express.Router();

router.get(
  '/',
  catchAsync(async function (req, res) {
    res.send(
      jsend.success(
        await Candidate.find({ voting: req.voting._id }).then((c) => Promise.all(c.map((c) => c.formatted(req))))
      )
    );
  })
);

// add new candidate
router.post(
  '/',
  [body('name').exists().withMessage('Name is required'), body('description').optional()],
  handleValidationErrors(),
  catchAsync(async function (req, res) {
    return res.send(
      jsend.success(
        await Candidate.create({
          name: req.body.name,
          description: req.body.description,
          voting: req.voting._id,
        }).then((c) => c.formatted(req))
      )
    );
  })
);

const singleCandidateRouter = express.Router();

router.use(
  '/:candidateId',
  [
    param('candidateId')
      .exists()
      .withMessage('Candidate ID is required')
      .custom(async function (candidateId, { req }) {
        req.candidate = await Candidate.findById(candidateId);
        if (!req.candidate) throw new Error('Candidate not found.');
        else return true;
      }),
  ],
  handleValidationErrors(),
  singleCandidateRouter
);

singleCandidateRouter.get(
  '/',
  catchAsync(async function (req, res) {
    return res.send(jsend.success(await req.candidate.formatted(req)));
  })
);

//edit details
singleCandidateRouter.put(
  '/',
  [body('name').exists().withMessage('Name is required'), body('description').optional()],
  handleValidationErrors(),
  catchAsync(async function (req, res) {
    req.candidate.name = req.body.name;
    req.candidate.description = req.body.description;
    await req.candidate.save();
    res.send(jsend.success(await req.candidate.formatted(req)));
  })
);

// delete single candidate
singleCandidateRouter.delete(
  '/',
  catchAsync(async function (req, res) {
    await req.candidate.remove();
    res.send(jsend.success({}));
  })
);

// set image

const imageStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, './src/images/');
  },
  filename: function (req, file, cb) {
    cb(
      null,
      'candidate_' +
        (req.candidate == undefined ? 'new' : req.candidate._id) +
        '_' +
        +new Date() +
        '.' +
        file.originalname.split('.').pop().toLocaleLowerCase()
    );
  },
});
const upload = multer({
  storage: imageStorage,
  limits: {
    fileSize: 4 * 1024 * 1024, // 4MB
  },
  fileFilter: (req, file, cb) => {
    function showError(message) {
      cb(null, false);
      return cb(new Error(message));
    }
    console.log(file.mimetype);
    if (file.mimetype.split('/')[0] != 'image') return showError('Only image files accepted.');
    cb(null, true);
  },
});

const imageRouter = new express.Router();

// adding image
singleCandidateRouter.post('/setImage', upload.single('image'), handleValidationErrors(), async function (req, res) {
  try {
    //adding new image
    if (req.file !== undefined) {
      if (req.file.fieldname === 'image') {
        // console.log("image exists")
        // req.currentPost.images.push(req.file.path);
        req.candidate.image = req.file.path;
        await req.candidate.save();
        return res.send(jsend.success(await req.candidate.formatted(req)));
      }
    }
    return res.send(jsend.fail('No file uploaded'));
  } catch (e) {
    res.json({
      status: 'error',
      data: e.toString(),
    });
  }
});

// voting a candidate
singleCandidateRouter.post(
  '/vote',
  [
    body('otpId')
      .exists()
      .withMessage('OTP is required')
      .custom(async function (otpId, {}) {
        const otp = await OTP.findById(otpId);
        if (!otp || !otp.isVerified) throw new Error('OTP invalid');
      }),
  ],
  handleValidationErrors(),
  catchAsync(async function (req, res) {
    const otp = await OTP.findById(req.body.otpId);

    const user = await User.findOne({ email: otp.receiverAddress });

    if (!user) throw new Error('User not found');

    const votes = await user.votesIn(req.voting._id);

    if (votes.length > 0) {
      votes.forEach(async (vote) => {
        await vote.remove();
      });
    }
    await Vote.create({
      candidate: req.candidate._id,
      user: user._id,
    });
    return res.send(jsend.success({}));
  })
);

module.exports = router;
