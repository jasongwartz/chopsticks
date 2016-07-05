
$('#bdbutton').on('click', ->
  $btn = $(this).button('loading')
  i = instruments.find( (ins) ->
    return ins.name == 'bd'
  )
  i.is_live = !i.is_live
  $btn.button('reset')
  )

$('#sdbutton').on('click', ->
  $btn = $(this).button('loading')
  i = instruments.find( (ins) ->
    return ins.name == 'sd'
  )
  i.is_live = !i.is_live
  $btn.button('reset')
  )

$('#cymbutton').on('click', ->
  $btn = $(this).button('loading')
  i = instruments.find( (ins) ->
    return ins.name == 'cym'
  )
  i.is_live = !i.is_live
  $btn.button('reset')
  )