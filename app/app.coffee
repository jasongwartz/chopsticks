###
Author: Jason Gwartz
2016
###

# Data store

sample_urls = [
    "../samples/drum_bass_hard.wav",
    "../samples/drum_snare_hard.wav",
    "../samples/drum_cymbal_closed.wav"
  ]


# Variable declarations with global scope

context = null
samples = null
t = null
final_gain = null
output_chain = null

# Class definitions

class LoadedSample
  # Objects of this class are playable samples which have been
    # loaded into memory and decoded (ie. are ready to be played)

  constructor: (@file) ->

    request = new XMLHttpRequest()
    request.open('GET', @file, true)
    request.responseType = 'arraybuffer'

    self = @
    request.onload = ->
      self.data = request.response
      context.decodeAudioData(self.data, (decoded) ->
        self.decoded = decoded
      , null)
    request.send()

  play: (n) ->
    if isNaN(n)
      return
    source = context.createBufferSource()
    source.buffer = @decoded
    source.connect(output_chain)
    source.start(n)
  

class PlaySound
  constructor: (@sample, @beat) -> # LoadedSample, integer

class SoundContainer
  constructor: ->
    @buffer = [] # array of PlaySounds

  prepare: ->
    t = context.currentTime
    loaded = true
    [(loaded = false if i.data is undefined) for i in samples]

    if not loaded
      alert("Samples still loading, please wait.")
    else
      inputs = ( ## TODO: make number of input fields variable
        document.getElementById(v).value.split(' ') for v in ["bd", "sd", "cym"]
      )

      (@.add(new PlaySound(
        samples[index], t + parseFloat(n)
        )
      ) for n in inputs[index] when ->
        console.log(isNaN(n))
        return !isNaN(n)
        # TODO: fix this, it doesn't do anything
        ) for index in [0...inputs.length]

  add: (p) -> # playSound
    @buffer.push(p)

  play: ->
    i.sample.play(i.beat) for i in @buffer


# Core utility function definitions

startPlayback = ->
  track = new SoundContainer()
  track.prepare()
  track.play()

  # TODO: Inactive tab problem
  setTimeout (->
    startPlayback()
    ), 4000
    # TODO: very slight early jump on succeeding phrase

# Preloader function definitions
track = null

main = ->
  window.AudioContext = window.AudioContext || window.webkitAudioContext
  context = new AudioContext()
  output_chain = context.createGain()
  
  final_gain = context.createGain()
  final_gain.connect(context.destination)

  samples = (new LoadedSample(i) for i in sample_urls)

  # TODO: find some sort of good callback system for loading samples!!
  loop
    console.log("in")
    ready = true
    (->
      ready = false
      console.log("not ready")
      setTimeout (->
        
        return
        ), 0.5
    ) for i in samples when i.data is undefined
    if ready
      console.log("ready")
      break

  # initiate the analyser

  analyser = context.createAnalyser()
  analyser.connect(final_gain)
  analyser.fftSize = 2048
  bufferLength = analyser.fftSize
  dataArray = new Uint8Array(bufferLength)

  #  https://github.com/mdn/voice-change-o-matic/blob/gh-pages/scripts/app.js#L123-L167

  HEIGHT = 100
  WIDTH = window.innerWidth

  canvas = document.getElementById("visual")
  canvas.width = WIDTH
  canvas.height = HEIGHT
  canvasCtx = canvas.getContext("2d")
  canvasCtx.clearRect(0, 0, WIDTH, HEIGHT)

  draw = ->

    drawVisual = requestAnimationFrame(draw)

    analyser.getByteTimeDomainData(dataArray)
    canvasCtx.fillStyle = 'rgb(255, 255, 255)'
    canvasCtx.fillRect(0, 0, WIDTH, HEIGHT)

    canvasCtx.lineWidth = 2
    canvasCtx.strokeStyle = 'rgb(0, 0, 0)'

    canvasCtx.beginPath()

    sliceWidth = WIDTH * 1.0 / bufferLength
    x = 0

    for i in [0...bufferLength]
      v = dataArray[i] / 128.0
      y = v * HEIGHT/2

      if i == 0
        canvasCtx.moveTo(x, y)
      else
        canvasCtx.lineTo(x, y)
      x += sliceWidth
    canvasCtx.lineTo(canvas.width, canvas.height/2)
    canvasCtx.stroke()

  draw()


  output_chain.connect(analyser)



# Script load-time functions

#main()