
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
        if not ui.draggable.hasClass("on-canvas")
          ui.draggable.clone().appendTo("#node-canvas")
            .addClass("on-canvas")
            .draggable(
              {
                helper:"original",
                scope:"canvas"
              }
            )
            .droppable( # node-wrappers accept node-sample
            # TODO: bug still exists when dropping wrapper with children
              {
                scope:"canvas",
                tolerance:"pointer",
                drop: (evt, ui) ->
                  if $(this).parent().is("#node-canvas")
                    loc = $(this).children().last()
                  else
                    loc = $(this).parent().children().last()
                  ui.draggable.appendTo($(this))
                    .position(
                      {
                        of: loc,
                        my: "top",
                        at: "bottom"
                      }
                    )
              }
            )
          
      else
        name = ui.draggable.find("h2").text()
        i = (x for x in instruments when x.name == name)[0] # the hacky part
        i.is_live = true

        # adding a new sound node to the canvas
        if !ui.draggable.hasClass("on-canvas")
          ui.draggable.clone().appendTo($("#node-canvas"))
            .addClass("on-canvas")
              .draggable(
                {
                  helper:"original",
                  scope:"canvas"
                }
              )

    out: (evt, ui) -> # not in use because nodes duplicate on drop (line 14)
      console.log("dragged out")
      name = ui.draggable.find("h2").text()
      i = (x for x in instruments when x.name == name)[0] # the hacky part
      i.is_live = false
  })

  # Drop node back on tray to disable
  $("#node-tray").droppable({
    scope:"canvas",
    drop: (evt, ui) ->
      # Handles children of wrapper
      names = ($(i).text() for i in ui.draggable.find("h2"))
      for name in names
        i = (x for x in instruments when x.name == name)[0] # the hacky part
        try
          i.is_live = false
        catch e
        #pass
      ui.draggable.remove()
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
      .appendTo($("#node-tray")) # append first, else 'position: relative' bug
      .draggable({scope:"tray", helper:"clone"})
      .addClass("node-wrapper").removeClass("node-sample")

node = (name, def_pat) ->
  return """<div class="node node-sample">
  <h2>#{ name }</h2>
</div>"""