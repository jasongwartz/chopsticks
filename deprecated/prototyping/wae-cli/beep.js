// beep.js
module.exports = (audioContext, frequency, duration) => {
  const osc = audioContext.createOscillator();
  const amp = audioContext.createGain();

  osc.frequency.value = frequency;
  osc.start(0);
  osc.stop(duration);
  osc.connect(amp);

  amp.gain.setValueAtTime(0.5, 0);
  amp.gain.linearRampToValueAtTime(0, duration);
  amp.connect(audioContext.destination);
};
