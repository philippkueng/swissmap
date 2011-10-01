$(document).ready(() ->

  # reset the pre coloring of the svg on the load event
  $("#container svg #cantons path").attr('fill', 'rgba(166,3,17,0)')
  
  # hide all the datatypes on load
  $("#datasets .categories .datatypes").hide()
  
  # show the datasets on click on the category title
  $("#datasets .categories li span").click(() ->
    $(this).next().toggle()
  )
  
  # make the datatype draggable
  $("#datasets .categories .datatypes li").draggable(revert: true)
  
  # make the target dropable
  $("#droptargets").droppable(
    drop: (event, ui) ->
      $(this).html('dropped "' + $(ui.draggable).html() + '", thanks')
      
      # trigger the showing
      
  )
)