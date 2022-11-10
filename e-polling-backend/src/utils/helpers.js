const { pathSeparator } = require("./constants");

//waiting n milliseconds
module.exports.wait = function (duration) {
    return new Promise(function (resolve, reject) {
        setTimeout(function () {
            resolve()
        }, duration)
    });
}

module.exports.formattedImagePath = function (req, imagePath) {
    let paths = imagePath.split(pathSeparator);
    const first = paths.shift();
    if (first != 'src') throw new Error("Image path should start from src folder.");
    return (req.protocol === 'https') ? 'https' : 'http' + "://" + req.headers.host + "/" + paths.join("/");
}