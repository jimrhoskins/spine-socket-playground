Spine ?= require 'spine'
DO_NOT_UPDATE_SERVER = "do not update server"

Spine.Model.Socket =
  extended: ->
    @change @changeSocket
    @fetch @fetchSocket

  changeSocket: (instance, action, options) ->
    unless options?.remoteOrigin
      @socket.emit "Spine:#{@className}:#{action}", instance
    else
      console.log 'Skipping update that originated from server'

  fetchSocket: ->
    @socket.emit "Spine:#{@className}:fetch", (results) =>
      @refresh results or [], clear: true

  connect: (socket) ->
    @socket = socket or io.connect()
    console.log @className, " connected with ", @socket

    @socket.on "Spine:#{@className}:create", (instance) =>
      console.log "Creating from socket", instance
      @create instance, {remoteOrigin: true}

    @socket.on "Spine:#{@className}:update", (instance) =>
      console.log "Update from socket", instance
      @find(instance.id).updateAttributes instance, {remoteOrigin: true}

    @socket.on "Spine:#{@className}:destroy", (instance) =>
      console.log "Destroying from socket", instance
      @find(instance.id).destroy(remoteOrigin: true)
module?.exports = Spine.Model.Socket
