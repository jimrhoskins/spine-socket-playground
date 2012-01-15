Spine = require('spine')

class PlayerEditController extends Spine.Controller
  events: 
    'submit form': 'formSubmitted'
    'click .destroy': 'destroyPlayer'

  elements:
    'form': 'form'

  constructor: ->
    super

  setPlayer: (@player) ->
    console.log 'SET Player', @player
    @render()

  render: =>
    if @player?
      @html require('views/player_edit')(@player) 
    else
      @html ''

  formSubmitted: (e) ->
    console.log e
    if @player
      @player.fromForm @form
      @player = @player.save()
    e.preventDefault()
    @setPlayer()
    
  destroyPlayer: (e) ->
    e.preventDefault()
    @player.destroy() if @player?
    @setPlayer()

module.exports = PlayerEditController
