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
analyser = null
final_gain = null

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

  play: (n, output_chain) ->
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

  play: (output_chain) ->
    i.sample.play(i.beat, output_chain) for i in @buffer

class JGAnalyser

  # NOTE NOTE NOTE the @ character is class-level, normal vars are instance

  constructor: ->
    @node = context.createAnalyser()
    @node.fftSize = 2048
    @bufferLength = @node.fftSize
    @dataArray = new Uint8Array(@bufferLength)

    #  https://github.com/mdn/voice-change-o-matic/blob/gh-pages/scripts/app.js#L123-L167

    @HEIGHT = 30
    @WIDTH = window.innerWidth
    

    @canvas = document.getElementById("visual")
    @canvas.width = @WIDTH
    @canvas.height = @HEIGHT
    @canvasCtx = @canvas.getContext("2d")
    @canvasCtx.clearRect(0, 0, @WIDTH, @HEIGHT)

  draw: =>
    # Reset width
    @WIDTH = window.innerWidth

    @canvasCtx.fillStyle = 'rgb(255, 255, 255)'
 #   @canvasCtx.strokeStyle = 'rgb(0, 0, 0)'

    drawVisual = requestAnimationFrame(@draw)
    @node.getByteTimeDomainData(@dataArray)
    
    @canvasCtx.fillRect(0, 0, @WIDTH, @HEIGHT)

    @canvasCtx.lineWidth = 2

    @canvasCtx.beginPath()

    sliceWidth = @WIDTH * 1.0 / @bufferLength
    x = 0

    for i in [0...@bufferLength]
      v = @dataArray[i] / 128.0
      y = v * @HEIGHT/2

      if i == 0
        @canvasCtx.moveTo(x, y)
      else
        @canvasCtx.lineTo(x, y)
      x += sliceWidth
    @canvasCtx.lineTo(@canvas.width, @canvas.height/2)
    @canvasCtx.stroke()
  
# Core utility function definitions

startPlayback = (output_chain) ->
  track = new SoundContainer()
  track.prepare()
  track.play(output_chain)
  analyser.canvasCtx.strokeStyle = 'rgb(0, 0, 0)'
  
  # Inner timer to change colour, indicate reloop
  setTimeout (->
    analyser.canvasCtx.strokeStyle = 'rgb(255, 0, 0)'
    ), 3500

  # Timer to keep in loop
  # TODO: Inactive tab problem
  setTimeout (->
    startPlayback(output_chain)
    ), 4000
    # TODO: very slight early jump on succeeding phrase


# Preloader function definitions

main = ->
  window.AudioContext = window.AudioContext || window.webkitAudioContext
  context = new AudioContext()

  # sources go into output_chain for "master" manipulation
  output_chain = context.createGain()
  # after all "master" controls, final_gain goes to output
  final_gain = context.createGain()
  
  # initiate the analyser
  analyser = new JGAnalyser()
  analyser.draw()

  # Wire up the components
  output_chain.connect(analyser.node)
  analyser.node.connect(final_gain)
  final_gain.connect(context.destination)
  
  samples = (new LoadedSample(i) for i in sample_urls)

  # TODO: New bug, first page load doesn't start playing automatically
  # TODO: find some sort of good callback system for loading samples!!
  init_samples = ->
    ready = true
    for i in samples
      if i.data is undefined
        ready = false
    if not ready
      console.log("Loading and decoding samples...")
      setTimeout(init_samples, 100)
    else
      console.log("Samples loaded. Starting playback.")
      startPlayback(output_chain)

  init_samples()

  return output_chain



# Script load-time functions

#main()