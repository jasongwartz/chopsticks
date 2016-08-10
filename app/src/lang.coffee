###
Author: Jason Gwartz
2016
###

class Wrapper
  # If condition, on_beats, for loop
  @instances = []
  constructor: (@name, extra_html) -> # TODO: create subclasses?
    Wrapper.instances.push(this)
    
    @html = """
      <div class="node node-wrapper" id="#{ @name }">
        <h2>#{ @name }</h2>
        #{ extra_html }
      </div>"""

  @parse_input: (str) ->
    return (parseInt(i) for i in str.replace(/\D/g," ").split(" "))

  eval_input: (jq) -> # parameter is the corresponding jquery object
    @check(
      jq.find("select").val(),
      jq.find("input").val(),
      jq
    )

class IfConditional extends Wrapper
  name = "If"
  extra_html = """
      <select class="form-control" id="if-select">
          <option value="beat">Beat</option>
          <option value="bar">Bar</option>
          <option value="phrase">Phrase</option>
        </select>
      <input type="text" id="if-input" class="form-control">
      """
  
  constructor: ->
    super(name, extra_html)


# TODO: for loop not yet implemented
class ForLoop extends Wrapper
  name = "For"
  extra_html = """
        <input type="text" id="for-input" class="form-control">
        <select class="form-control" id="for-select">
            <option value="beat">Beats</option>
            <option value="bar">Bars</option>
            <option value="phrase">Phrases</option>
          </select>
  """ # extra html

  constructor: ->
    super(name, extra_html)

  for_loop: (loop_block, number_loops) ->
    if loop_block is "phrases"
      pass()
    else if loop_block is "bars"
      pass()
    else if loop_block is "beats"
      pass()

class SoundNode
  @tray_instances = []
  @canvas_instances = []
  constructor: (@instrument) ->
    node_number = (
      i for i in SoundNode.canvas_instances when i.instrument is @instrument
      ).length + 1
    
    @id = switch node_number
      when 1 then @instrument.name
      else @instrument.name + node_number

    @wrappers = {
      conditionals: {},
      forloops: {}
    }
    @playing_phrases = []

    @html = """
    <div class="node-sample-container" id="#{ @id }-container">
      <div class="wrappers">
      </div>
      <div class="node node-sample" id="#{ @id }">
        <h2>#{ @id }</h2>
      </div>
      </div>"""

  phrase_eval: ->
    @wrappers.conditionals = {}
    c = @wrappers.conditionals

    for w in $("##{ @id }-container").find(".wrappers")
      c[$(i).find("select").val()] = {
        input: Wrapper.parse_input(
          $(i).find("input").val()
        ),
        data: $(i).data("Wrapper")
      } for i in $(w).children("#If")

    if c.phrase?
      playing_phrases = c.phrase.input
      if phrase not in playing_phrases
        return # exit phrase_eval() - not playing this phrase
    else
      playing_phrases = []
    
    if c.bar?
      if c.beat?
        bar_beats = []
        for br in c.bar.input
          for bt in c.beat.input
            # algorithm = beat + ( bar - 1 ) * 4
            bar_beats.push(bt + ((br - 1) * 4))
        @instrument.add(p) for p in bar_beats
      else
        bar_beats = (1 + (i-1) * 4 for i in c.bar.input)
        @instrument.add(p) for p in bar_beats
      return

    if c.beat?
      bar_beats = []
      for br in [1..4]
        for bt in c.beat.input
          # algorithm = beat + ( bar - 1 ) * 4
          bar_beats.push(bt + ((br - 1) * 4))
      @instrument.add(p) for p in bar_beats