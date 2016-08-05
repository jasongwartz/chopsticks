###
Author: Jason Gwartz
2016
###

# Variable declarations with global scope

context = null
samples = null
instruments = null
sample_data = null
t = null
analyser = null
final_gain = null
phrase = 1
beat = 0
bar = 1
tempo = 500.0 # milliseconds per beat - 1000 = 60bpm

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
    # TODO: P1: samples don't load from remote server in safari, 40% in chrome
      self.data = request.response
      context.decodeAudioData(self.data, (decoded) ->
        self.decoded = decoded
      , (e) ->
        console.log("Error loading:" + self.file + e))
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

  play: (output) ->
    @sample.play(@beat, output)

class Instrument
  constructor: (@name, @data) ->
    @is_live = false
    @pattern = [] # array of PlaySounds

  load: ->
    @sample = new LoadedSample(@data.file)

  is_loaded: ->
    return @sample.data? # Check if not undefined/null

  add: (beat) -> # playSound
    @pattern.push(new PlaySound(@sample, beat))
  
  reset: ->
    @pattern = []

class SoundContainer
  constructor: ->
    @active_instruments = [] # array of Instruments
  prepare: ->
    i.reset() for i in instruments
    t = context.currentTime
    @active_instruments.push(i) for i in instruments when i.is_live

    # Adds all beats from default pattern
    for i in @active_instruments
      i.add(
        parseFloat(n) + t
      ) for n in i.data.default_pattern.split(' ')

    # TODO: how to prepare times, knowing that
      # the computation time is inconsistent
  play: (output_chain) ->
    for instrument in @active_instruments # calls into lang.js
      ps.play(output_chain) for ps in instrument.pattern

class JGAnalyser

  constructor: ->
    @node = context.createAnalyser()
    @node.fftSize = 2048
    @bufferLength = @node.fftSize
    @dataArray = new Uint8Array(@bufferLength)

    #  https://github.com/mdn/voice-change-o-matic/blob/gh-pages/scripts/app.js#L123-L167

    @canvas = document.getElementById("visual")
    @HEIGHT = 30
    @WIDTH = $(@canvas).parent().width()
    
    #console.log(typeof()
    
    @canvas.width = @WIDTH
    @canvas.height = @HEIGHT
    @canvasCtx = @canvas.getContext("2d")
    @canvasCtx.clearRect(0, 0, @WIDTH, @HEIGHT)

  draw: =>
    # Reset width
    @WIDTH = $(@canvas).parent().width()
    
    # TODO: fix bug where auto-resizing canvas breaks the colours
    #@canvas.width = @WIDTH
    @canvasCtx.fillStyle = 'rgb(255, 255, 255)'

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
  # change analyser colour back to black
  analyser.canvasCtx.strokeStyle = 'rgb(0, 0, 0)'
  
  # Inner timer to change colour, indicate reloop
  setTimeout(->
    analyser.canvasCtx.strokeStyle = 'rgb(255, 0, 0)'
  , (tempo * 16 - tempo * 2))

  beat_increment = ->
    # only set time-out within a bar
    # the auto-reload of the phrase will trigger the call
    beat += 1
    update_beat_labels()
    if beat is 4
      beat = 0
      if bar is 4
        bar = 1
        phrase += 1
      else
        bar += 1
        setTimeout(->
          beat_increment()
        , tempo)
    else
      setTimeout(->
        beat_increment()
      , tempo)
  
  beat_increment() # call

  # Timer to keep in loop
  # TODO: Inactive tab problem
  setTimeout(->
    startPlayback(output_chain)
  , tempo * 16)
    # TODO: very slight early jump on succeeding phrase


# Preloader function definitions

main = ->
# is called by 'onload=', thus runs slightly after $("document").ready
# TODO: on iOS, trigger main() from button instead of onload
  
  # async load sample data from JSON
  $.getJSON("static/sampledata.json", (result) ->
    sample_data = result

    # Init all the Instrument and SoundNode objects
    instruments = (new Instrument(d, v) for d, v of sample_data)
    i.load() for i in instruments
    SoundNode.tray_instances.push(
      new SoundNode(i)
    ) for i in instruments # calls into lang.coffee
    ui_init()  # Initialise the button listeners

    # TODO: BUG Safari only: first page load doesn't start playing automatically
    # closer to fixing it using this indented callback but not quite
    init_samples = ->
      ready = true
      for i in instruments
        if i.sample.decoded is undefined
          ready = false
      if not ready
        console.log(i.name + ": " + i.is_loaded() for i in instruments)
        setTimeout(init_samples, 1000)
      else
        console.log(i.name + ": " + i.is_loaded() for i in instruments)
        console.log("All samples loaded.")
        startPlayback(output_chain)

    init_samples()
  )
  
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

