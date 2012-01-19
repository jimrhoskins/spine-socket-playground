require 'coffee-script'
express = require 'express'
hem = require './lib/connect-hem'
less = require './lib/connect-less'
SocketServer = require './lib/socket-server.spine'
FileSave = require './lib/file.spine'

global.window = {}
Spine = require 'spine'
delete global.window


app = express.createServer()
io = require('socket.io').listen(app)

app.configure ->
  app.set 'views', "#{__dirname}/views"

  app.use hem
    slugFile: "#{__dirname}/slug.json"

  app.use '/application.css', less
    source: "#{__dirname}/less/bootstrap.less"
    paths: ["#{__dirname}/less"]



app.get '/', (req, res) ->
  res.render 'index.jade', layout: false





class Player extends Spine.Model
  @configure 'Player', 'name', 'state', 'x', 'y'
  @extend SocketServer
  @extend FileSave



Player.fetch()
Player.connect io



namespace = (klass, name) ->
  name ?= "f#{Math.random()}"

  class Clone extends klass
    @configure @className, @attributes...
    @room = name


open = null

id = "A"

io.sockets.on 'connection', (socket) ->
  if open and open.sockets.length < 2
    open.onConnect socket
    console.log 'Connected to ', open.room
  else
    console.log "FOOOP", open?.sockets?.length
    open = namespace Player, id
    open.connect io
    open.onConnect socket
    console.log 'Created ', open.room
    id = id + "A"



app.listen process.env.PORT || 3000
console.log "Server running on port #{app.address().port}"
