package = require 'hem/lib/package'
fs = require 'fs'

module.exports = (options = {}) ->

  jsPath = options.jsPath or '/application.js'

  config = {}
  keys = ['dependencies', 'libs', 'paths']

  if options.slugFile
    slug = JSON.parse fs.readFileSync options.slugFile
    config[key] = slug[key] for key in keys when slug[key]?

  config[key] = options[key] for key in keys when options[key]?

  console.log config

  pkg = package.createPackage config

  serveJavaScript = (req, res, next) ->
    res.header 'Content-Type', 'text/javascript'
    res.send pkg.compile()


  # Middleware
  (req, res, next) ->
    if req.method is 'GET' and req.path is jsPath
      return serveJavaScript req, res, next
    next()


