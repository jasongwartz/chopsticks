###
Author: Jason Gwartz
2016
###

class Wrapper
  # If condition, on_beats, for loop
  @instances = []
  constructor: (@name, @check, extra_html) -> # TODO: create subclasses?
    Wrapper.instances.push(this)
    
    @html = """
      <div class="node node-wrapper" id="#{ @name }">
        <h2>#{ @name }</h2>
        #{ extra_html }
      </div>"""

  eval_input: (jq) -> # parameter is the corresponding jquery object
    @check(
      jq.find("select").val(),
      jq.find("input").val(),
      jq
    )

# TODO: conditional not yet implemented
if_conditional = new Wrapper("If", (condition_to_check, input, jq) ->
  input = (parseInt(i) for i in input.replace(/\D/g," ").split(" "))
  if condition_to_check is "phrase"
    # var phrase is singleton from other .js file
    return (phrase + 1) in input # returns true if playing on next phrase
  else if condition_to_check is "bar"
    do_something
  else if condition_to_check is "beat"
    ins = jq.parent().parent().data("SoundNode").instrument
    ins.add(i) for i in input
    return true # If no phrase specified, assume to be true
, """
      <select class="form-control" id="if-select">
          <option value="beat">Beat</option>
          <option value="bar">Bar</option>
          <option value="phrase">Phrase</option>
        </select>
      <input type="text" id="if-input" class="form-control">
""" # extra html
)

# TODO: for loop not yet implemented
for_loop = new Wrapper("For", (loop_block, number_loops) ->
  if loop_block is "phrases"
    pass()
  else if loop_block is "bars"
    pass()
  else if loop_block is "beats"
    pass()
,  """
      <input type="text" id="for-input" class="form-control">
      <select class="form-control" id="for-select">
          <option value="beat">Beats</option>
          <option value="bar">Bars</option>
          <option value="phrase">Phrases</option>
        </select>
""" # extra html
)

class SoundNode
  @tray_instances = []
  @canvas_instances = []
  constructor: (@instrument) ->
    @id = @instrument.name
    @wrappers = []
    @html = """
    <div class="node-sample-container" id="#{ @id }-container">
      <div class="wrappers">
      </div>
      <div class="node node-sample" id="#{ @id }">
        <h2>#{ @id }</h2>
      </div>
      </div>"""

  phrase_eval: ->
    wrappers = $("##{ @id }-container")
      .find(".node-wrapper")
    for w in wrappers
      w = $(w)
      w.data("Wrapper").eval_input(w)
