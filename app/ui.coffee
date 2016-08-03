###
Author: Jason Gwartz
2016
###

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
              # TODO: clean this up for parent hierarchy
                # drag/drop both directions, keep sound-node as last child
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

  # add sound nodes to tray
  $(n.html).appendTo($("#node-tray"))
    .draggable(
      {
        helper:"clone",
        scope:"tray"
      }
    ).data("SoundNode", n) for n in SoundNode.tray_instances

  $(w.html).appendTo($("#node-tray"))
    .draggable(
      {
        scope:"tray",
        helper:"clone"
      }
    ).data("Wrapper", w) for w in Wrapper.instances


update_beat_labels = ->
  $("#beat_label").text(phrase + ":" + beat)
#  $("#phrase_label").text(phrase)