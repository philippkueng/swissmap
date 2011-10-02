$(document).ready(() ->

  # reset the pre coloring of the svg-switzerland-map on the load event
  $("#container svg #cantons path").attr('fill', 'rgba(166,3,17,0)')
  
  # hide all the datasets on load
  $("#datasets .categories .datatypes").hide()
  
  # show the datasets on click on the category title
  $("#datasets .categories li span").click(() ->
    $(this).next().toggle()
  )
  
  window.target1_dataset = ""
  window.target2_dataset = ""
  window.interpolate_values = false
  window.highest_interpolated_value = 0
  
  apply_color_to_canton = (canton, percentage) ->
    console.log("canton of #{canton.canton} with #{percentage}%")
  
    if percentage?
      if window.interpolate_values
        percentage = ((100 * percentage) / window.highest_interpolated_value)
      
      # assumption that the data format for the percentage value was like 94.4123% and not 0.944123
      if percentage >= 0
        $("#container svg g#cantons path[id='#{canton.canton}']}").attr('fill', "rgba(166,3,17,#{(percentage / 100)})")
      else
        $("#container svg g#cantons path[id='#{canton.canton}']}").attr('fill', "rgba(49,0,98,#{(percentage / 100)})")  
    else
      $("#container svg g#cantons path[id='#{canton.canton}']}").attr('fill', 'url(#gridPattern)')
      # $("#container svg g#cantons path[id='#{canton.canton}']}").attr('stroke','green')
      # $("#container svg g#cantons path[id='#{canton.canton}']}").attr('stroke-width', '4')
      # $("#container svg g#cantons path[id='#{canton.canton}']}").attr('stroke-dasharray','2 2 2 2')
      # $("#container svg g#cantons path[id='#{canton.canton}']}").attr('style','stroke:white;stroke-width:3;')
      # $("#container svg g#cantons path[id='#{canton.canton}']}").attr('fill','green')
       
  # make the target dropable
  $("#target1").droppable(
    drop: (event, ui) ->
      # check which element was dropped and find the according key for it
      name = $(ui.draggable).attr('id')
      window.target1_dataset = name
      
      $('#target1').html("<span>#{$(ui.draggable).html()}</span>")
      
      # Interpolate the color range, because it's difficult to see differences for low percent values
      if window.interpolate_values
        window.highest_interpolated_value = 0
        get_highest_value = (canton) ->
          if canton[name] != "" and parseFloat(canton[name]) >= window.highest_interpolated_value
            window.highest_interpolated_value = parseFloat(canton[name])
          else
            if canton[name] != "" and (parseFloat(canton[name]) * -1) >= window.highest_interpolated_value
              window.highest_interpolated_value = parseFloat(canton[name] * -1)
              
        (get_highest_value canton for canton in window.swissmapdata.data)
      
      (apply_color_to_canton canton, (if canton[name] is "" then null else parseFloat(canton[name])) for canton in window.swissmapdata.data)  
  )
  
  $("#target2").droppable(
    drop: (event, ui) ->
      
      if window.target1_dataset == ""
        alert('Could you please put the first dataset in the area on the left? ...pretty please.')
      else
        name = $(ui.draggable).attr('id')
        window.target2_dataset = name
        $('#target2').html("<span>#{$(ui.draggable).html()}</span>")
    
        window.highest_value = 0
        get_highest_value = (canton) ->
          first_dataset = parseFloat(canton[window.target1_dataset])
          second_dataset = parseFloat(canton[window.target2_dataset])      
          result = first_dataset / second_dataset
          if result >= window.highest_value
            window.highest_value = result
          if (result * -1) >= window.highest_value
            window.highest_value = (result * -1)
          
        (get_highest_value canton for canton in window.swissmapdata.data)
    
        console.log(window.highest_value)
        
        apply_divided_color_to_canton = (canton) ->
          first_dataset = parseFloat(canton[window.target1_dataset])
          second_dataset = parseFloat(canton[window.target2_dataset])
      
          result = first_dataset / second_dataset
          
          if result >= 0
            result_percentage = (result / window.highest_value)
            $("#container svg g#cantons path[id='#{canton.canton}']").attr('fill', "rgba(166,3,17,#{result_percentage})")
          else
            result_percentage = ((result * -1) / window.highest_value)
            $("#container svg g#cantons path[id='#{canton.canton}']").attr('fill', "rgba(49,0,98,#{result_percentage})")
      
        (apply_divided_color_to_canton canton for canton in window.swissmapdata.data)
  )

  # loading all the assets
  $('#datasets ul.datatypes').html("")
  
  add_new_dataset = (definition) ->
    get_key_and_value = (key,value) ->
      if key.match(/percentage/)
        $('#datasets ul.datatypes').append("<li id='#{key}'>#{value}</li>")
  
    (get_key_and_value key,value for own key,value of definition)  
  (add_new_dataset definition for definition in window.swissmapdata.definitions)

  # make the datatype draggable
  $("#datasets .categories .datatypes li").draggable(revert: true)

  # Hook up the click events to the cantons to show additional information on click.
  $("#container svg g#cantons path").click(() ->
    $("<div><strong>Canton:</strong> #{$(this).attr('id')}<br/><strong>Percentage:</strong> #{(parseFloat($(this).attr('fill').replace('rgba(166,3,17,','').replace(')','')) * 100)}%</div>").dialog()
  )
  
  # correc webkit-svg bug as reported here: http://stackoverflow.com/questions/7570917/svg-height-incorrectly-calculated-in-webkit-browsers
  fix_webkit_height_bug = () ->
    svgW = 1052.363
    svgH = 744.094
    cur_svgW = $("#map svg").width()
    new_svgH = (svgH / svgW) * cur_svgW
    $("#map svg").height(new_svgH)
  if $.browser.webkit
    $(window).resize(() ->
      fix_webkit_height_bug()
    )
    fix_webkit_height_bug()
)