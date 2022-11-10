const jsend = {

    success: function(data){
        return {
            status: 'success',
            data
        }
    },
    error: function(message, data){
        return {
            status: 'error',
            message, data
        }
    },
    fail: function(message, data){
        return {
            status: "fail", message, data
        }
    }

}

module.exports = jsend