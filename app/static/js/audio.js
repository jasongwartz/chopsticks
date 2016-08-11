// Generated by CoffeeScript 1.10.0

/*
Author: Jason Gwartz
2016
 */
var Instrument, JGAnalyser, LoadedSample, PlaySound, SoundContainer, analyser, bar, beat, context, final_gain, main, output_chain, phrase, playing, sample_data, samples, startPlayback, t, tempo,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

context = null;

samples = null;

sample_data = null;

t = null;

analyser = null;

final_gain = null;

phrase = 1;

beat = 0;

bar = 1;

tempo = 500.0;

playing = false;

output_chain = null;

LoadedSample = (function() {
  function LoadedSample(file) {
    var request, self;
    this.file = file;
    request = new XMLHttpRequest();
    request.open('GET', this.file, true);
    request.responseType = 'arraybuffer';
    self = this;
    request.onload = function() {
      self.data = request.response;
      return context.decodeAudioData(self.data, function(decoded) {
        return self.decoded = decoded;
      }, function(e) {
        return console.log("Error loading:" + self.file + e);
      });
    };
    request.send();
  }

  LoadedSample.prototype.play = function(output_chain, n) {
    var source;
    if (isNaN(n)) {
      return;
    }
    source = context.createBufferSource();
    source.buffer = this.decoded;
    source.connect(output_chain);
    return source.start(n);
  };

  return LoadedSample;

})();

PlaySound = (function() {
  function PlaySound(sample, beat1) {
    this.sample = sample;
    this.beat = beat1;
    this.beat = (this.beat - 1) * tempo / 1000;
  }

  PlaySound.prototype.play = function(output, time_reference) {
    return this.sample.play(output, this.beat + time_reference);
  };

  return PlaySound;

})();

Instrument = (function() {
  Instrument.instances = [];

  function Instrument(name, data) {
    this.name = name;
    this.data = data;
    Instrument.instances.push(this);
    this.pattern = {};
  }

  Instrument.prototype.load = function() {
    return this.sample = new LoadedSample(this.data.file);
  };

  Instrument.prototype.is_loaded = function() {
    return this.sample.data != null;
  };

  Instrument.prototype.add = function(beat) {
    return this.pattern[beat] = new PlaySound(this.sample, beat);
  };

  Instrument.reset = function() {
    var i, j, len, ref, results;
    ref = Instrument.instances;
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      i = ref[j];
      results.push(i.pattern = {});
    }
    return results;
  };

  return Instrument;

})();

SoundContainer = (function() {
  function SoundContainer() {
    this.active_instruments = [];
  }

  SoundContainer.prototype.prepare = function(phrase_time) {
    var j, len, ref, results, s;
    Instrument.reset();
    ref = SoundNode.canvas_instances;
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      s = ref[j];
      results.push(s.phrase_eval());
    }
    return results;
  };

  SoundContainer.prototype.play = function(output_chain, phr_time) {
    var b, instrument, j, len, ps, ref, results;
    ref = Instrument.instances;
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      instrument = ref[j];
      results.push((function() {
        var ref1, results1;
        ref1 = instrument.pattern;
        results1 = [];
        for (b in ref1) {
          ps = ref1[b];
          results1.push(ps.play(output_chain, phr_time));
        }
        return results1;
      })());
    }
    return results;
  };

  return SoundContainer;

})();

JGAnalyser = (function() {
  function JGAnalyser() {
    this.draw = bind(this.draw, this);
    this.node = context.createAnalyser();
    this.node.fftSize = 2048;
    this.bufferLength = this.node.fftSize;
    this.dataArray = new Uint8Array(this.bufferLength);
    this.canvas = document.getElementById("visual");
    this.HEIGHT = 30;
    this.WIDTH = $(this.canvas).parent().width();
    this.canvas.width = this.WIDTH;
    this.canvas.height = this.HEIGHT;
    this.canvasCtx = this.canvas.getContext("2d");
    this.canvasCtx.clearRect(0, 0, this.WIDTH, this.HEIGHT);
  }

  JGAnalyser.prototype.draw = function() {
    var drawVisual, i, j, ref, sliceWidth, v, x, y;
    this.WIDTH = $(this.canvas).parent().width();
    this.canvasCtx.fillStyle = 'rgb(255, 255, 255)';
    drawVisual = requestAnimationFrame(this.draw);
    this.node.getByteTimeDomainData(this.dataArray);
    this.canvasCtx.fillRect(0, 0, this.WIDTH, this.HEIGHT);
    this.canvasCtx.lineWidth = 2;
    this.canvasCtx.beginPath();
    sliceWidth = this.WIDTH * 1.0 / this.bufferLength;
    x = 0;
    for (i = j = 0, ref = this.bufferLength; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
      v = this.dataArray[i] / 128.0;
      y = v * this.HEIGHT / 2;
      if (i === 0) {
        this.canvasCtx.moveTo(x, y);
      } else {
        this.canvasCtx.lineTo(x, y);
      }
      x += sliceWidth;
    }
    this.canvasCtx.lineTo(this.canvas.width, this.canvas.height / 2);
    return this.canvasCtx.stroke();
  };

  return JGAnalyser;

})();

startPlayback = function(output_chain) {
  var beat_increment, track;
  track = new SoundContainer();
  track.prepare();
  track.play(output_chain, context.currentTime);
  analyser.canvasCtx.strokeStyle = 'rgb(0, 0, 0)';
  setTimeout(function() {
    return analyser.canvasCtx.strokeStyle = 'rgb(255, 0, 0)';
  }, tempo * 16 - tempo * 2);
  beat_increment = function() {
    beat += 1;
    update_beat_labels();
    if (beat === 4) {
      beat = 0;
      if (bar === 4) {
        bar = 1;
        return phrase += 1;
      } else {
        bar += 1;
        return setTimeout(function() {
          return beat_increment();
        }, tempo);
      }
    } else {
      return setTimeout(function() {
        return beat_increment();
      }, tempo);
    }
  };
  beat_increment();
  return setTimeout(function() {
    return startPlayback(output_chain);
  }, tempo * 16);
};

main = function() {
  $.getJSON("static/sampledata.json", function(result) {
    var d, i, init_samples, j, k, len, len1, ref, ref1, v;
    sample_data = result;
    for (d in sample_data) {
      v = sample_data[d];
      new Instrument(d, v);
    }
    ref = Instrument.instances;
    for (j = 0, len = ref.length; j < len; j++) {
      i = ref[j];
      i.load();
    }
    ref1 = Instrument.instances;
    for (k = 0, len1 = ref1.length; k < len1; k++) {
      i = ref1[k];
      SoundNode.tray_instances.push(new SoundNode(i));
    }
    ui_init();
    init_samples = function() {
      var l, len2, ready, ref2;
      ready = true;
      ref2 = Instrument.instances;
      for (l = 0, len2 = ref2.length; l < len2; l++) {
        i = ref2[l];
        if (i.sample.decoded === void 0) {
          ready = false;
        }
      }
      if (!ready) {
        console.log((function() {
          var len3, m, ref3, results;
          ref3 = Instrument.instances;
          results = [];
          for (m = 0, len3 = ref3.length; m < len3; m++) {
            i = ref3[m];
            results.push(i.name + ": " + i.is_loaded());
          }
          return results;
        })());
        return setTimeout(init_samples, 1000);
      } else {
        console.log((function() {
          var len3, m, ref3, results;
          ref3 = Instrument.instances;
          results = [];
          for (m = 0, len3 = ref3.length; m < len3; m++) {
            i = ref3[m];
            results.push(i.name + ": " + i.is_loaded());
          }
          return results;
        })());
        return console.log("All samples loaded.");
      }
    };
    return init_samples();
  });
  window.AudioContext = window.AudioContext || window.webkitAudioContext;
  context = new AudioContext();
  output_chain = context.createGain();
  final_gain = context.createGain();
  analyser = new JGAnalyser();
  analyser.draw();
  output_chain.connect(analyser.node);
  analyser.node.connect(final_gain);
  return final_gain.connect(context.destination);
};
