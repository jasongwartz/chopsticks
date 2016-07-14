
$("document").ready(->

  $("#node-canvas").droppable({
   # accept: true,
    hoverClass: "node-canvas-hover",
    activeClass: "node-canvas-hover",
    tolerance: "pointer",
    drop: (evt, ui) ->
      name = ui.draggable.find("h2").text()
      i = (x for x in instruments when x.name == name)[0] # the hacky part
      i.is_live = true
    out: (evt, ui) ->
      name = ui.draggable.find("h2").text()
      i = (x for x in instruments when x.name == name)[0] # the hacky part
      i.is_live = false
  })


)

ui_init = ->

  $(
    node(n.name, n.data.default_pattern)
    ).appendTo($("#node-tray")) for n in instruments
  $(".node").draggable()

  # TODO: Now does correctly toggle each instrument, next: make it less hacky!
  $(".node").each( (index, element) ->
    btn = $(element).find("button")
    name = $(element).find("input").attr("id")
    btn.on("click", ->
#      $(btn).button('reset')
    )
  )

node = (name, def_pat) ->
  return """<div class="node">
  <h2>#{ name }</h2>
  <input type="text" id="#{ name }" class="form-control" value="#{ def_pat }">
  <br />
<button type="button" id="#{ name }button" class="btn btn-primary btn-block" data-toggle="button" autocomplete="off">
#{ name }
</button>
</div>"""