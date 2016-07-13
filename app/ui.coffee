
ui_init = ->

  # TODO: Now does correctly toggle each instrument, next: make it less hacky!
  $(".input-group").each( (index, element) ->
    btn = $(element).find("button")
    name = $(element).find("input").attr("id")
    btn.on("click", ->
      i = (x for x in instruments when x.name == name)[0]
      i.is_live = !i.is_live
 
#      $(btn).button('reset')
    )

  )