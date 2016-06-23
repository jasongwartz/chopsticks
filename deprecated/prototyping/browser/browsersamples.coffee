console.log("started")

window.AudioContext = window.AudioContext || window.webkitAudioContext
context = new AudioContext()

class LoadedBuffer
  constructor: (@file) ->
  
  init: ->
    self = @
    request = new XMLHttpRequest()
    request.open('GET', @file, true)
    request.responseType = 'arraybuffer'

    request.onload = ->
      self.data = request.response
      console.log("loaded")
      load = true
      [load = false if i.data is undefined] for i in arr
      if load
        playall()
      
    request.send()
    
  play: (n) ->
    
    context.decodeAudioData(@data, (decoded) ->
      @source = context.createBufferSource()
      @source.buffer = decoded
      @source.connect(context.destination)
      @source.start(n)
      console.log("playing")
      #@source.onended = @source.stop()
    , null)

    

a = new LoadedBuffer("../samples/drum_bass_hard.wav")
b = new LoadedBuffer("../samples/drum_cymbal_closed.wav")
c = new LoadedBuffer("../samples/drum_snare_hard.wav")

arr = [a, b, c]

a.init()
b.init()
c.init()

playall = ->
  console.log("playall")
  a.play(i) for i in [0..8] by 2
  b.play(j) for j in [0..8] by 0.5
  c.play(k) for k in [1..8] by 2


