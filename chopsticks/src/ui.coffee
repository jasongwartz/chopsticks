###
Author: Jason Gwartz
2016
###

# Page-load UI code

$(document).ready(->

  if /Safari/.test(navigator.userAgent)
    true # TODO: figure out way to handle refresh-needed bug

  ios = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream
  if ios
    $( "#ios-start" ).modal().on("hidden.bs.modal", ->
      main()
    )
  else
    main()

  document.addEventListener("visibilitychange", ->
    # Uses the PageVisibility API
    if not context?
      return
    if context.state is "running"
      context.suspend()
    else
      context.resume()
  )
)


# Core UI code: initialises the tray with all available nodes,
#   and sets up the canvas with necessary listeners and events,
#   defines behavior for all interactions between nodes

ui_init = ->
  # add sound nodes to tray
  $(n.html).appendTo($("#sn-tray"))
    .draggable(
      {
        helper:"clone"
      }
    )
    .data("SoundNode", n)
    .on("click", ->
      $(@).data("SoundNode").instrument.tryout(context.currentTime)
    ) for n in SoundNode.tray_instances

  # add wrappers to tray
  $(w.html).appendTo($("#wrapper-tray"))
    .draggable(
      {
        helper:"clone"
      }
    ).data("Wrapper", w) for w in [new IfConditional(), new ForLoop()]


  # Init the canvas, draggable/droppable events and click listeners
  #   for the canvas and the node duplicates created on drop

  playing = false # defined at ui_init() call time, accessed in .drop() below
  $("#node-canvas").droppable(
    {
      hoverClass: "node-canvas-hover",
      tolerance: "pointer",
      drop: (evt, ui) ->

        if not playing
          # init playback on first node drop
          playing = true
          startPlayback()

        if ui.draggable.hasClass("on-canvas")
          return
        # code path for node-wrappers
        if ui.draggable.hasClass("node-wrapper")
        
          ui.draggable.clone().appendTo("#node-canvas")
            .addClass("on-canvas")
            .draggable()
            .data("Wrapper", ui.draggable.data("Wrapper"))
            .position(
              {
                of: evt
              }
            )
            
        else # code path for Sound Nodes
          # adding a new sound node to the canvas
          sn = ui.draggable.data("SoundNode")
          new_sn = new SoundNode(sn.instrument)
          SoundNode.canvas_instances.push(new_sn)

          $(new_sn.html).appendTo($("#node-canvas"))
            .addClass("on-canvas")
            .data("SoundNode", new_sn)
            .data("live", true)
            .position(
              {
                of: evt
              }
            )
            .each(->
              xy_compute(@)
            )
            .draggable(
              {
                helper:"original",
                scope:"canvas",
                distance: 15
                drag: (evt, ui) ->
                # implemented only for one instance of a SoundNode at a time
                  xy_compute(@)
                stop: (evt, ui) ->
                  $(evt.toElement).one('click', (e) ->
                    e.stopImmediatePropagation()
                  )
                # source: http://stackoverflow.com/questions/3486760/
            # how-to-avoid-jquery-ui-draggable-from-also-triggering-click-event
              }
            )
            .on("click", (e) ->
              if not $(e.target).hasClass("node-toggle")
                return
              ns = $(@).find(".node-sample")
              if $(@).data("live")
                ns.addClass("node-disabled")
                $(@).data("live", false)
              else
                ns.removeClass("node-disabled")
                $(@).data("live", true)
            )
            .droppable(
              {
                accept: ".node-wrapper",
                greedy: true,
                tolerance:"pointer",
                drop: (evt, ui) ->
                  if ui.draggable.hasClass("on-canvas")
                    w = ui.draggable
                  else
                    w = ui.draggable.clone()

                  w.appendTo($(this).find(".wrappers"))
                    .position(
                      {
                        of: $(this).find(".node-sample"),
                        my: "bottom",
                        at: "top"
                      }
                    ).css("top", "0px")
                    .data("Wrapper", ui.draggable.data("Wrapper"))
                    .data("live": true)
                    # .data() calls may be duplicated if node was
                      # already on canvas, but are necessary if not
                    .on("click", "*:not(input,select)", ->
                      if $(@).parent().data("live")
                        $(@).parent().addClass("node-disabled")
                          .data("live", false)
                      else
                        $(@).parent().removeClass("node-disabled")
                          .data("live", true)
                    )
              }
            )
            .find(".wrappers").sortable(
              {
                stop: (evt, ui) ->
                  # done sorting
              }
            )
    }
  )

  # Drop node back on tray to disable
  $("#node-tray").droppable(
    {
    scope:"canvas",
    drop: (evt, ui) ->
      ui.draggable.remove()
    }
  )

# UI Utility Functions

xy_compute = (t) ->
  # Parameter input is a jQuery object, including .data parameter of
  #   node's corresponding SoundNode lang object

  canvas = $("#node-canvas")
  sn = $(t).find(".node-sample")

  # gain is currently based on SoundNode
     # may consider changing it to node-container
  gain = 1 - (
    sn.offset().top - canvas.offset().top
  ) / canvas.height()

  lpf = Instrument.compute_filter(
    sn.offset().left / canvas.width()
    )

  $(t).data()
    .SoundNode.instrument
    .gain.gain.value = gain
  
  $(t).data()
    .SoundNode.instrument
    .filter.frequency.value = lpf

update_beat_labels = ->
  # Small function to set UI labels to values at call-time
  $("##{ n }_label").text(i) for n, i of {
    "phrase": phrase,
    "beat": beat,
    "bar": bar
  }