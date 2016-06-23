fs = require("fs")

class LoadedBuffer
  constructor: (@filename) ->

  init: ->
    

  play: (n) ->
    audioContext.decodeAudioData(@filename).then (@decodedData) ->
      @source = audioContext.createBufferSource()
      @source.buffer = @decodedData
      @source.connect(audioContext.destination)
      @source.start(n)
      @source.onended = x


a = new LoadedBuffer(fs.readFileSync("./drum_bass_hard.wav"))
b = new LoadedBuffer(fs.readFileSync("./drum_cymbal_closed.wav"))
c = new LoadedBuffer(fs.readFileSync("./drum_snare_hard.wav"))

a.play(i) for i in [0..8] by 2
b.play(j) for j in [0..8] by 0.5
c.play(k) for k in [1..8] by 2




