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
    request.send()

  play: (n) ->
    context.decodeAudioData(@data, (decoded) ->
      @source = context.createBufferSource()
      @source.buffer = decoded
      @source.connect(context.destination)
      #console.log("n = " + n)
      @source.start(n)
    , null)

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
      ) for n in inputs[index] when (n) ->
        n is not NaN
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


# Preloader function definitions
track = null

main = ->
  window.AudioContext = window.AudioContext || window.webkitAudioContext
  context = new AudioContext()

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



# Script load-time functions

main()