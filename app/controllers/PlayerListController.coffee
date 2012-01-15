Spine = require('spine')
require 'spine/lib/list'
Player = require('models/Player')

class PlayerListController extends Spine.List
  constructor: ->
    super
    @items = Player.all()
    Player.bind 'change refresh', =>
      @items = Player.all()
      @render()
    @render()

  template: require('views/player')
    
module.exports = PlayerListController
