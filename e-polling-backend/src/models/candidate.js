const mongoose = require('mongoose');
const { formattedImagePath } = require('../utils/helpers');
const Vote = require('./vote');

const candidateSchema = mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    image: {
      type: String,
    },
    voting: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Voting',
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

candidateSchema.methods.formatted = async function (req) {

    return {
      ...this.toObject(),
      votes: await Vote.countDocuments({ candidate: this._id }),
      image: !this.image ? undefined : formattedImagePath(req, this.image),
    };

}

const Candidate = mongoose.model('Candidate', candidateSchema);
module.exports = Candidate;