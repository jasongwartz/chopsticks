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
      console.log("n = " + n)
      @source.start(n)
    , null)

class PlaySound
  constructor: (@sample, @beat) ->

class SoundContainer
  constructor: ->
    @buffer = []

  




# Core utility function definitions

play = ->
  t = context.currentTime
  loaded = true
  [(loaded = false if i.data is undefined) for i in samples]
  
  if not loaded
    alert("Samples still loading, please wait.")
  else
    bd_beats =
      (t + parseFloat(n)) for n in document.
        getElementById('bd').value.split(' ') when (n) ->
          if n is NaN
            return false

    sd_beats =
      (t + parseFloat(n)) for n in document.
        getElementById('sd').value.split(' ') when (n) ->
          if n is NaN
            return false
    
    cym_beats =
      (t + parseFloat(n)) for n in document.
        getElementById('cym').value.split(' ') when (n) ->
          if n is NaN
            return false

    console.log(sd_beats)
    samples[0].play(i) for i in bd_beats
    samples[1].play(i) for i in cym_beats
    samples[2].play(i) for i in sd_beats
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
  

  samples = (new LoadedSample(i) for i in sample_urls)

# Script load-time functions

main()