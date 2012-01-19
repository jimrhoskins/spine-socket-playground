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


module.exports = SocketServer
