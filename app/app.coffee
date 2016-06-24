###
Author: Jason Gwartz
2016
###

# Data store

sample_urls = [
    "../samples/drum_bass_hard.wav",
    "../samples/drum_cymbal_closed.wav",
    "../samples/drum_snare_hard.wav"
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
      @source.start(n)
    , null)


# Core utility function definitions

play = ->

  loaded = true
  [(loaded = false if i.data is undefined) for i in samples]
  
  if not loaded
    alert("Samples still loading, please wait.")
  else
    return play_patterns


play_patterns = {

  drumbeat: ->
    samples[0].play(i) for i in [t..t+8]
    samples[1].play(j) for j in [t..t+8] by 0.25
    samples[2].play(k) for k in [t+0.5..t+8]

  bass_drum: ->
    samples[0].play(i) for i in [t..t+8]

}

# Preloader function definitions

main = ->
  window.AudioContext = window.AudioContext || window.webkitAudioContext
  context = new AudioContext()
  t = context.currentTime

  samples = (new LoadedSample(i) for i in sample_urls)

# Script load-time functions

main()