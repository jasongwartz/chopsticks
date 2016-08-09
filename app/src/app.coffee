###
Author: Jason Gwartz
2016
###

# Variable declarations with global scope

context = null
samples = null
sample_data = null
t = null
analyser = null
final_gain = null
phrase = 1
beat = 0
bar = 1
tempo = 500.0 # milliseconds per beat - 1000 = 60bpm
playing = false
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
    # TODO: P1: samples don't load from remote server in safari, 40% in chrome
      self.data = request.response
      context.decodeAudioData(self.data, (decoded) ->
        self.decoded = decoded
      , (e) ->
        console.log("Error loading:" + self.file + e))
    request.send()

  play: (output_chain, n) ->
    if isNaN(n)
      return
    source = context.createBufferSource()
    source.buffer = @decoded
    source.connect(output_chain)
    source.start(n)

class PlaySound
  constructor: (@sample, @beat) -> # LoadedSample, integer
    # milliseconds to seconds conversion, account for off by one
    @beat = (@beat - 1) * tempo / 1000
  play: (output, time_reference) ->
    @sample.play(output, @beat + time_reference)

class Instrument
  @instances = []
  constructor: (@name, @data) ->
    Instrument.instances.push(this)
    @is_live = false
    @pattern = [] # array of PlaySounds

  load: ->
    @sample = new LoadedSample(@data.file)

  is_loaded: ->
    return @sample.data? # Check if not undefined/null

  add: (beat) -> # playSound
    @pattern.push(new PlaySound(@sample, beat)) # beat 1 - 16
  
  @reset: ->
    for i in @instances
      i.pattern = []

class SoundContainer
  constructor: ->
    @active_instruments = [] # array of Instruments
  prepare: (phrase_time) ->
    Instrument.reset()
    for s in SoundNode.canvas_instances
      s.phrase_eval()

  play: (output_chain, phr_time) ->
    for node in SoundNode.canvas_instances # calls into lang.js
      ps.play(output_chain, phr_time) for ps in node.instrument.pattern

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

startPlayback = (output_chain, phrase_start_time) ->
  console.log("phrase start = " + phrase_start_time)
  track = new SoundContainer()
  track.prepare()
  track.play(output_chain, phrase_start_time)

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
        setTimeout(-> # TODO: async bug here, might be from tab switching
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
    startPlayback(
      output_chain,
      (
        phrase_start_time + (tempo * 16 / 1000)
      )
    )
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
    new Instrument(d, v) for d, v of sample_data
    i.load() for i in Instrument.instances
    SoundNode.tray_instances.push(
      new SoundNode(i)
    ) for i in Instrument.instances # calls into lang.coffee
    ui_init()  # Initialise the button listeners

    # TODO: BUG Safari only: first page load doesn't start playing automatically
    # closer to fixing it using this indented callback but not quite
    init_samples = ->
      ready = true
      for i in Instrument.instances
        if i.sample.decoded is undefined
          ready = false
      if not ready
        console.log(i.name + ": " + i.is_loaded() for i in Instrument.instances)
        setTimeout(init_samples, 1000)
      else
        console.log(i.name + ": " + i.is_loaded() for i in Instrument.instances)
        console.log("All samples loaded.")
        #startPlayback(output_chain)

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

