
$("document").ready(->

  $("#node-canvas").droppable({
   # accept: true,
    hoverClass: "node-canvas-hover",
 #   activeClass: "node-canvas-hover",
    tolerance: "pointer",
    scope:"tray", # only accepts new drops from tray
    drop: (evt, ui) ->

      # code path for node-wrappers
      if ui.draggable.hasClass("node-wrapper")
        if !ui.draggable.hasClass("on-canvas")
          
          $("#node-canvas").append(
            ui.draggable.clone()
              .addClass("on-canvas")
              .draggable(
                {
                  helper:"original",
                  scope:"canvas"
                }
              )
              .droppable(
                {
                  scope:"canvas",
                  tolerance:"pointer",
                  drop: (evt, ui) ->
                    console.log("Accepted!")
                }
              )
            )
          
      else
        name = ui.draggable.find("h2").text()
        i = (x for x in instruments when x.name == name)[0] # the hacky part
        i.is_live = true

        # adding a new sound node to the canvas
        if !ui.draggable.hasClass("on-canvas")
          $("#node-canvas").append(
            ui.draggable.clone()
              .addClass("on-canvas")
              .draggable(
                {
                  helper:"original",
                  scope:"canvas"
                }
              )
            )
 

    out: (evt, ui) -> # not in use because nodes duplicate on drop (line 14)
      name = ui.draggable.find("h2").text()
      i = (x for x in instruments when x.name == name)[0] # the hacky part
      i.is_live = false
  })


)

ui_init = ->

  # add nodes to tray
  $(
    node(n.name, n.data.default_pattern)
    ).appendTo($("#node-tray")) for n in instruments
  # make nodes draggable - drags 'clone' from tray
  $(".node").draggable({helper:"clone", scope:"tray"})

  # TODO: Now does correctly toggle each instrument, next: make it less hacky!
  $(".node").each( (index, element) ->
    btn = $(element).find("button")
    name = $(element).find("input").attr("id")
    btn.on("click", ->
#      $(btn).button('reset')
    )
  )

  $(
    node("wrapper", "")
    )
      .draggable({scope:"tray", helper:"clone"})
      .addClass("node-wrapper").removeClass("node")
      .appendTo($("#node-tray"))

node = (name, def_pat) ->
  return """<div class="node">
  <h2>#{ name }</h2>
  <input type="text" id="#{ name }" class="form-control" value="#{ def_pat }">
  <br />
<button type="button" id="#{ name }button" class="btn btn-primary" data-toggle="button" autocomplete="off">
#{ name }
</button>
</div>"""