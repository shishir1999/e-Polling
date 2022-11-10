const mongoose = require('mongoose');
const voteSchema = mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        candidate: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Candidate',
            required: true,
        },
    },
    {
        timestamps: true,
    }
);



const Vote = mongoose.model('Vote', voteSchema);
module.exports = Vote;