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
        return console.log "Read Error", err
      @refresh data.toString() , clear: true


module.exports = FileSave
