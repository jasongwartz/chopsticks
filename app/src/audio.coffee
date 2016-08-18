###
Author: Jason Gwartz
2016
###

# Variable declarations with global scope

context = null
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

  constructor: (@file, @stretch = null) ->

    request = new XMLHttpRequest()
    request.open('GET', @file, true)
    request.responseType = 'arraybuffer'

    request.onload = =>
    # TODO: P1: samples don't load from remote server in safari, 40% in chrome
      @data = request.response
      context.decodeAudioData(@data, (decoded) =>
        @decoded = decoded # @decoded is of type AudioBuffer
      , (e) ->
        console.log("Error loading:" + @file + e))
    request.send()

  play: (output, n) ->
    if isNaN(n)
      return
    source = context.createBufferSource()
    source.buffer = @decoded
    source.playbackRate.value = do =>
      if @stretch?
        @decoded.duration / (tempo/1000 * @stretch)
      else
        1
        # TODO: trim samples so they dont play overthemselves = intereference
    source.connect(output)
    source.start(n)
    return [n, source]

class Instrument
  @instances = []
  @maxFrequency =  null

  constructor: (@name, @data) ->
    Instrument.instances.push(this)
    @pattern = [] # array of beats
    
    @filter = context.createBiquadFilter()
    @filter.type = 'lowpass'
    @filter.frequency.value = Instrument.maxFrequency
    @gain = context.createGain()

  load: ->
    if @data.beat_stretch?
      @sample = new LoadedSample(@data.file, @data.beat_stretch)
    else
      @sample = new LoadedSample(@data.file)

  is_loaded: ->
    return @sample.decoded? # Check if not undefined/null

  add: (b) -> # playSound
    @pattern.push(b) if b not in @pattern
    # beat 1 - 16
  
  play: (output_chain, time) ->
    @filter.connect(@gain)
    @gain.connect(output_chain)
    previous_buffer = null
    do (=>
      b = (i - 1) * tempo / 1000 + time
      # milliseconds to seconds conversion, account for off by one
      if previous_buffer? and (
        previous_buffer[0] + @sample.decoded.duration >= b
      )
        previous_buffer[1].stop(b)
        # TODO: creates 'slapping' sound when it stops

      previous_buffer = @sample.play(@filter, b)
    ) for i in @pattern

  @reset: ->
    i.pattern = [] for i in Instrument.instances

  @computeMaxFrequency: ->
    Instrument.maxFrequency = context.sampleRate / 2
  
    
  @compute_filter: (rate) ->
    if not Instrument.maxFrequency?
      Instrument.computeMaxFrequency()
    # Source: http://www.html5rocks.com/en/tutorials/
    # webaudio/intro/js/filter-sample.js
    minValue = 40
    console.log(Instrument.maxFrequency)
    #// Logarithm (base 2) to compute how many octaves fall in the range.
    numberOfOctaves = Math.log(Instrument.maxFrequency / minValue) / Math.LN2
    #// Compute a multiplier from 0 to 1 based on an exponential scale.
    mult = Math.pow(2, numberOfOctaves * (
      rate - 1.0
      ))
    #// Get back to the frequency value between min and max.
    return Instrument.maxFrequency * mult

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

startPlayback = (output_chain) ->
  Instrument.reset()
  s.phrase_eval() for s in SoundNode.canvas_instances
  instrument.play(
    output_chain, context.currentTime
  ) for instrument in Instrument.instances
    # this may be unnecessarily iterating over all instruments, not just live

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
        if not i.is_loaded()
          ready = false
      if not ready
        console.log("Still loading: " + (
          " " + i.name for i in Instrument.instances when not i.is_loaded()
          )
        )
        setTimeout(init_samples, 100)
      else
        console.log("All samples loaded.")

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

