describe 'Player', ->
  Player = null
  
  beforeEach ->
    class Player extends Spine.Model
      @configure 'Player'
  
  it 'can noop', ->
    