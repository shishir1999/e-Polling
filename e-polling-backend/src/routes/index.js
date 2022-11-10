const express = require('express');
const { pathSeparator } = require('../utils/constants');
const authRoute = require('./auth.route');
const userRoute = require('./user.route');
const fs = require('fs');
const router = express.Router();

router.get('/', function (req, res) {
  res.send('Good Boy');
});

const defaultRoutes = [
  {
    path: '/auth',
    route: authRoute,
  },
  {
    path: '/users',
    route: userRoute,
  },
];

defaultRoutes.forEach((route) => {
  router.use(route.path, route.route);
});

const dirPath = 'src/images'.split('/').join(pathSeparator);
if (!fs.existsSync(dirPath)) {
  fs.mkdirSync(dirPath);
  console.log('Created new Directory ' + dirPath);
}
router.use('/' + 'images', express.static(dirPath));

router.use('/votings', require('./voting'));

module.exports = router;
