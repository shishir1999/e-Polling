module.exports  = function(req, res, next){
    // extracting page, limit and sortBy from queryString
    req.paginationOptions = {} ;
    if(('page' in req.query) && parseInt(req.query.page).toString() != 'NaN'){
        req.paginationOptions.page = parseInt(req.query.page) ;
    }
    if(('limit' in req.query) && parseInt(req.query.limit).toString() != 'NaN'){
        req.paginationOptions.limit = parseInt(req.query.limit) ;
    }

    if(('sortBy' in req.query) ){
        req.paginationOptions.sortBy = req.query.sortBy.trim() ;
    }
    // console.log("Pagination Options: ", req.paginationOptions)
    next() ;
}