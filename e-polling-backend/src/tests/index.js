const mongoose = require('mongoose');
const config = require('../config/config');
const logger = require('../config/logger');
const Playback = require('../models/playback');

async function test() {
//   Playback.parseTime({hour: 12, minute: 59, meridian: 'AM'});
}

function logAndExit(e) {
  console.log(e);
  process.exit(0);
}

mongoose.connect(config.mongoose.url, config.mongoose.options).then(async () => {
  logger.info('Connected to MongoDB');
  await test().then(logAndExit).catch(logAndExit);
});
