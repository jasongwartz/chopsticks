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

  check: (condition_to_check, input, jq) ->
    input = (parseInt(i) for i in input.replace(/\D/g," ").split(" "))
    if condition_to_check is "phrase"
      # var phrase is singleton from other .js file
      return (phrase + 1) in input # returns true if playing on next phrase
    else if condition_to_check is "bar"
      console.log(jq)
      jq.parent().find("#node-wrapper")
      console.log(recurse)
      if recurse?
        recurse.data("Wrapper").eval_input(recurse)
    else if condition_to_check is "beat"
      ins = jq.parent().parent().data("SoundNode").instrument
      ins.add(i) for i in input
      return true # If no phrase specified, assume to be true

# TODO: for loop not yet implemented
class ForLoop extends Wrapper
  @name = "For"
  @extra_html = """
        <input type="text" id="for-input" class="form-control">
        <select class="form-control" id="for-select">
            <option value="beat">Beats</option>
            <option value="bar">Bars</option>
            <option value="phrase">Phrases</option>
          </select>
  """ # extra html
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
    conditionals = {}
    conditionals[$(i).find("select").val()] = $(i).data("Wrapper") for i in $("##{ @id }-container").find(".wrappers").children("#If")

    console.log(conditionals)
    if conditionals.phrase?
      to_cont = conditionals.phrase.eval_input()
      # finish implementing

    else if conditionals.bar?
      console.log("bar")
    else
      console.log("beat")

#    for w in wrappers
 #     w = $(w)
  #    w.data("Wrapper").eval_input(w)
