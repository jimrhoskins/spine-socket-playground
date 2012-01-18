require 'coffee-script'
express = require 'express'
hemConnect = require './hemConnect'
lessConnect = require './lessConnect'

global.window = {}
Spine = require 'spine'
delete global.window


app = express.createServer()
io = require('socket.io').listen(app)

app.configure ->
  app.set 'views', "#{__dirname}/views"

  app.use hemConnect
    slugFile: "#{__dirname}/slug.json"

  app.use '/application.css', lessConnect
    source: "#{__dirname}/less/bootstrap.less"
    paths: ["#{__dirname}/less"]



app.get '/', (req, res) ->
  res.render 'index.jade', layout: false




SocketServer = 
  extended: ->

  connect: (@io, options={}) -> 
    if options.autoConnect
      @io.sockets.on 'connection', @proxy(@onConnect)
    @sockets = []

  onConnect: (socket) ->
    if @room
      console.log 'Joined', @room
      socket.join @room

    @sockets.push socket

    socket.on 'disconnect', =>
      @sockets = (s for s in @sockets when s isnt socket)

    socket.on "Spine:#{@className}:create", (instance) =>
      console.log "CREATE", instance
      @socketBroadcast socket, "Spine:#{@className}:create", instance
      @create instance

    socket.on "Spine:#{@className}:update", (instance) =>
      console.log "UPDATE", instance
      @socketBroadcast socket, "Spine:#{@className}:update", instance
      @exists(instance.id)?.updateAttributes instance

    socket.on "Spine:#{@className}:destroy", (instance) =>
      console.log "DESTROY", instance
      @socketBroadcast socket, "Spine:#{@className}:destroy", instance
      @exists(instance.id)?.destroy()

    socket.on "Spine:#{@className}:fetch", (callback) =>
      console.log "FETCH", @all().toString()
      callback @all()

  socketEmit: (event, args...) ->
    @io.sockets.in(@room).emit(event, args...)


  socketBroadcast: (socket, event, args...) ->
    socket.broadcast.to(@room).emit(event, args...)
    console.log "broadcast", @room, event, args

fs = require 'fs'
FileSave = 
  extended: ->
    @change @changeLocal
    @fetch @fetchLocal
    @file ?= "#{@className}.json"

  changeLocal: ->
    data = JSON.stringify(@)
    fs.writeFile @file, data


  fetchLocal: ->
    fs.readFile @file, (err, data) =>
      if err
        console.log "Read Error"
        return
      @refresh data.toString() , clear: true


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
