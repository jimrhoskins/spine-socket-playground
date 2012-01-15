require 'coffee-script'
express = require 'express'
hemConnect = require './hemConnect'
lessConnect = require './lessConnect'

Spine = require 'spine'


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

  connect: (@io) -> 
    console.log 'CONNECttt'
    @io.sockets.on 'connection', @proxy(@onConnect)

  onConnect: (socket) ->
    console.log 'Socket Connection!'

    socket.on "Spine:#{@className}:create", (instance) =>
      console.log "CREATE", instance
      socket.broadcast.emit "Spine:#{@className}:create", instance
      @create instance

    socket.on "Spine:#{@className}:update", (instance) =>
      console.log "UPDATE", instance
      socket.broadcast.emit "Spine:#{@className}:update", instance
      @find(instance.id).updateAttributes instance

    socket.on "Spine:#{@className}:destroy", (instance) =>
      console.log "DESTROY", instance
      socket.broadcast.emit "Spine:#{@className}:destroy", instance
      @find(instance.id).destroy()

    socket.on "Spine:#{@className}:fetch", (callback) =>
      console.log "FETCH", @all().toString()
      callback @all()

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
























app.listen process.env.PORT || 3000
console.log "Server running on port #{app.address().port}"
