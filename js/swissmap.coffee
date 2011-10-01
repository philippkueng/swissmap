$(document).ready(() ->

  # reset the pre coloring of the svg on the load event
  $("#container svg #cantons path").attr('fill', 'rgba(166,3,17,0)')
  
  # hide all the datatypes on load
  $("#datasets .categories .datatypes").hide()
  
  # show the datasets on click on the category title
  $("#datasets .categories li span").click(() ->
    $(this).next().toggle()
  )
  
  window.target1_dataset = ""
  window.target2_dataset = ""
  
  # make the target dropable
  $("#target1").droppable(
    drop: (event, ui) ->
      # check which element was dropped and find the according key for it
      name = $(ui.draggable).attr('id')
      window.target1_dataset = name
      
      $('#target1').html("<span>#{$(ui.draggable).html()}</span>")
      
      apply_color_to_canton = (canton) ->
        $("#container svg g#cantons path[id='#{canton.canton}']").attr('fill', "rgba(166,3,17,0.#{canton[name].replace('.','')})")
        
      (apply_color_to_canton canton for canton in window.swissmapdata.data)  
      
      # alert("got #{name}")
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
          
        (get_highest_value canton for canton in window.swissmapdata.data)
    
        console.log(window.highest_value)
        
        apply_divided_color_to_canton = (canton) ->
          first_dataset = parseFloat(canton[window.target1_dataset])
          second_dataset = parseFloat(canton[window.target2_dataset])
          
          console.log(first_dataset)
          console.log(second_dataset)
      
          result = first_dataset / second_dataset
          
          console.log(result)
          console.log(window.higest_value)
          
          # a_percent = window.highest_value / 100
          # console.log(a_percent)
          # result_percentage = result / a_percent
          temp = result * 100
          result_percentage = (temp / window.highest_value) / 100
          console.log("result percentage" + result_percentage)
          
          $("#container svg g#cantons path[id='#{canton.canton}']").attr('fill', "rgba(166,3,17,#{result_percentage})")
          
          # check if the value is negative
          # first_dataset = parseFloat("0.#{canton.replace('.','')}")
      
        (apply_divided_color_to_canton canton for canton in window.swissmapdata.data)
  )

  # loading all the assets
  $('#datasets ul.datatypes').html("")
  
  add_new_dataset = (definition) ->
    get_key_and_value = (key,value) ->
      if key.match(/percentage/)
        $('#datasets ul.datatypes').append("<li id='#{key}'>#{value}</li>")
      # if (myString.match(/regex/)) { /*Success!*/ }
  
    (get_key_and_value key,value for own key,value of definition)  
  (add_new_dataset definition for definition in window.swissmapdata.definitions)

  # make the datatype draggable
  $("#datasets .categories .datatypes li").draggable(revert: true)

  $("#container svg g#cantons path").click(() ->
    alert("you've just selected #{$(this).attr('id')} and the percentage value is: #{(parseFloat($(this).attr('fill').replace('rgba(166,3,17,','').replace(')','')) * 100)}%")
  )
  # alert(window.swissmapdata)
  # console.log(window.swissmapdata)
  
  # $("#droptargets").droppable(
  #   drop: (event, ui) ->
  #     $(this).html('dropped "' + $(ui.draggable).html() + '", thanks')
  #     
  #     # trigger the showing
  #     
  # )
)