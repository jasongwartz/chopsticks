#context = new AudioContext()
analyser = audioContext.createAnalyser()
audio0 = new Audio()
audio0.src = 'drum_bass_hard.wav'
audio0.controls = true
#    audio0.autoplay = true;
audio0.loop = true
source = context.createMediaElementSource(audio0)
source.connect(analyser)
analyser.connect(context.destination)