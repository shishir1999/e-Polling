module.exports.randomNumberBetween = function(low, high){
    return Math.round(Math.random() * (high - low)) + low ;
}