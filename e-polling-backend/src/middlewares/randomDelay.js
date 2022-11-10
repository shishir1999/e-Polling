const { wait } = require("../utils/helpers");

const randomDelay = async function (req, res, next) {
    const {max, min} = {max: 3000,min: 100} ;
    const delay = Math.floor(Math.random() * (max - min + 1) + min);
    await wait(delay);
    console.log("Delayed by: " + delay + "ms");
    next();
}

module.exports = randomDelay