
canvas_init = ->

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
          
      else # code path for Sound Nodes

        sn = ui.draggable.data("SoundNode")
        new_sn = new SoundNode(sn.instrument)
        SoundNode.canvas_instances.push(new_sn)

        i = new_sn.instrument
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
              .data("SoundNode", new_sn)
  })

  # Drop node back on tray to disable
  $("#node-tray").droppable({
    scope:"canvas",
    drop: (evt, ui) ->
      # Handles children of wrapper
      sn = ui.draggable.find(".node-sample").data("SoundNode")
      sn.is_live = false # TODO: This will be redundant, remove!
      ui.draggable.remove()
  })


ui_init = ->

  canvas_init() # changed to happen in ui_init call, not on document.ready()

  # add nodes to tray
  $(n.html).appendTo($("#node-tray"))
    .data("SoundNode", n) for n in SoundNode.tray_instances

  # make nodes draggable - drags 'clone' from tray
  $(".node").draggable({helper:"clone", scope:"tray"})

  # TODO: Now does correctly toggle each instrument, next: make it less hacky!
  $(".node").each( (index, element) ->
    btn = $(element).find("button")
    btn.on("click", ->
#      $(btn).button('reset')
    )
  )

  $(
    """
      <div class="node node-wrapper" id="wrapper">
        <h2>wrapper</h2>
      </div>"""
    )
      .appendTo($("#node-tray")) # append first, else 'position: relative' bug
      .draggable({scope:"tray", helper:"clone"})
      .addClass("node-wrapper").removeClass("node-sample")


update_beat_labels = ->
  $("#beat_label").text(phrase + ":" + beat)
#  $("#phrase_label").text(phrase)