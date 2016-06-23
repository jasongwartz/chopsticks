amp = audioContext.createGain()

class AudioBuffer
  constructor: (@pitch) ->
    
    @osc = audioContext.createOscillator()
    @osc.type = "sawtooth"
    @osc.frequency.setValueAtTime(@pitch, 0)
    @osc.connect(amp)

startstop = (o, x) ->
  o.osc.start(x)
  o.osc.stop(x + 2)

startstop(new AudioBuffer(440 + i*10), i) for i in [0..12] by 2

#osc.onended()
 #   process.exit()

#amp.gain.setValueAtTime(0.25, 0)
#amp.gain.linearRampToValueAtTime(0, 2)
amp.connect(audioContext.destination)
