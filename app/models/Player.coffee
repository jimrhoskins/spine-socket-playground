Spine = require('spine')
require ('lib/spine.socket')

class Player extends Spine.Model
  @configure 'Player', 'name', 'state', 'x', 'y'

module.exports = Player
