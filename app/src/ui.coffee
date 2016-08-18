###
Author: Jason Gwartz
2016
###

canvas_init = ->

  glob = @ # to pass global vars to evt listeners

  $("#node-canvas").droppable({
    hoverClass: "node-canvas-hover",
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
            .data("Wrapper", ui.draggable.data("Wrapper"))
          
      else # code path for Sound Nodes

        # adding a new sound node to the canvas
        if !ui.draggable.hasClass("on-canvas")

          sn = ui.draggable.data("SoundNode")
          new_sn = new SoundNode(sn.instrument)
          SoundNode.canvas_instances.push(new_sn)

          $(new_sn.html).appendTo($("#node-canvas"))
            .addClass("on-canvas")
              .draggable(
                {
                  helper:"original",
                  scope:"canvas",
                  drag: (evt, ui) ->
                    canvas = $("#node-canvas")

                    sn = $(@).find(".node-sample")
                    
                    gain = 1 - (
                      sn.offset().top - canvas.offset().top
                    ) / canvas.height()
                    # gain is currently based on SoundNode
                    # may consider changing it to node-container
                    $(@).data()
                      .SoundNode.instrument
                      .gain.gain.value = gain
                    
                    lpf = Instrument.compute_filter(
                      sn.offset().left / canvas.width()
                      )
                      
                    $(@).data()
                      .SoundNode.instrument
                      .filter.frequency.value = lpf
                }
              )
              .droppable(
                {
                  accept: ".node-wrapper",
                  scope:"canvas",
                  tolerance:"pointer",
                  drop: (evt, ui) ->
                    ui.draggable.appendTo($(this).find(".wrappers"))
                      .draggable("disable")
                      .position(
                        {
                          of: $(this).find(".node-sample"),
                          my: "bottom",
                          at: "top"
                        }
                      ).css("top", "0px")
                }
              )
              .data("SoundNode", new_sn)
              .find(".wrappers").sortable(
                {
                  stop: (evt, ui) ->
                    # done sorting
                }
              )
              
      if not glob.playing
        # init playback on first node drop
        glob.playing = true
        startPlayback(output_chain)
  })

  # Drop node back on tray to disable
  $("#node-tray").droppable({
    scope:"canvas",
    drop: (evt, ui) ->
      # Handles children of wrapper
      sn = ui.draggable.find(".node-sample").data("SoundNode")
      ui.draggable.remove()
  })

ui_init = ->

  canvas_init() # changed to happen in ui_init call, not on document.ready()

  # add sound nodes to tray
  $(n.html).appendTo($("#sn-tray"))
    .draggable(
      {
        helper:"clone",
        scope:"tray"
      }
    )
    .data("SoundNode", n) for n in SoundNode.tray_instances

  # add wrappers to tray
  $(w.html).appendTo($("#wrapper-tray"))
    .draggable(
      {
        scope:"tray",
        helper:"clone"
      }
    ).data("Wrapper", w) for w in [new IfConditional(), new ForLoop()]


update_beat_labels = ->
  $("##{ n }_label").text(i) for n, i of {
    "phrase": phrase,
    "beat": beat,
    "bar": bar
  }