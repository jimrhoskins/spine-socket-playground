less = require 'less'
fs = require 'fs'
module.exports = (options = {}) ->
  throw "options.source required" unless options.source

  paths = options.paths or []


  # Middleware
  (req, res, next) ->
    fs.readFile options.source, (err, txt) ->
      less.render txt.toString(), {paths: paths}, (err, css) ->
        res.header 'Content-Type', 'text/css'
        res.send css
    
