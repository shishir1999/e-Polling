const mongoose = require('mongoose');
const { votingStatus } = require('../utils/constants');
const Candidate = require('./candidate');


const votingSchema = mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: false,
      trim: true,
    },
    status: {
      type: String,
      required: true,
      enum: Object.values(votingStatus),
      default: votingStatus.shown,
    },
    from: {
      type: Date,
      required: true,
    },
    to: {
      type: Date,
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

votingSchema.methods.formatted = async function (req) {
  let voting = this;
  const candidates = await Candidate.find({ voting: this._id }).then((candidates) =>
    Promise.all(candidates.map((candidate) => candidate.formatted(req)))
  );

  return {
    _id: this._id,
    title: this.title,
    description: this.description,
    status: this.status,
    from: this.from,
    to: this.to,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt,
    candidates,
  };
};

const Voting = mongoose.model('Voting', votingSchema);

module.exports = Voting;
