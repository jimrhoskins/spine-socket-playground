require('lib/setup')
Player = require('models/Player')

Spine = require('spine')
PlayerListController = require 'controllers/PlayerListController'
PlayerEditController = require 'controllers/PlayerEditController'

class App extends Spine.Controller
  constructor: ->
    super
    Player.extend Spine.Model.Socket
    Player.connect()

    @list = new PlayerListController el: $('#list')
    @edit = new PlayerEditController el: $('#edit')

    @list.bind 'change', (player) =>
      console.log 'Active Change', arguments
      @edit.setPlayer player

    Player.fetch()

  events: 
    'click #new': 'newPlayer'

  newPlayer: =>
    console.log 'new!'
    @edit.setPlayer new Player


window.Player = Player

module.exports = App
    
