
fs = require("fs")


bass = fs.readFileSync("./drum_bass_hard.wav")

play = (n) ->
  audioContext.decodeAudioData(bass).then (decodedData) ->
    source = audioContext.createBufferSource()
    source.buffer = decodedData

    source.connect(audioContext.destination)
    #source.loop = true
    source.start(n)
    source.stop(n+2)
#    source.


play(i) for i in [0..10] by 2



# XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest
# xhr = new XMLHttpRequest()
# request = new XMLHttpRequest()

# request.open('GET', 'amen.mp3', true)

# request.responseType = 'arraybuffer'
