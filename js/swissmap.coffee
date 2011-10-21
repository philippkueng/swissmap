$(document).ready(() ->

  # Global Variables
  window.dataset1 = null
  window.dataset2 = null
  window.current_map =
    type: null
    cantons: []
    key1: null
    key2: null
    
    
  # **Warnings**
  #
  # Dataset could not be read
  warning_dataset_could_not_be_read = () ->
    alert("Dataset could not be read, please reload the page. If that error keeps coming back please contact us.")


  # Reset the pre-coloring of the svg-switzerland-map on the load event.
  $("#container svg #cantons path").attr('fill', 'rgba(166,3,17,0)')
    
    
  # **get\_canton\_from\_current\_map\_cantons**
  #
  # Iterates over the current_map.cantons array and returns the object with the appropriate canton.name property
  get_canton_from_current_map_cantons = (canton_id) ->
    canton_object = null
    is_correct_canton = (canton) ->
      if canton.name == canton_id
        canton_object = canton
    (is_correct_canton canton for canton in window.current_map.cantons)
    return canton_object
    
    
  # **apply\_calculations\_to\_map**
  #
  # Iterates through the current_map.cantons array and applies every canton the given transparency. Makes it red if value is positive and blue if negative.
  apply_calculations_to_map = () ->
    color_canton = (canton) ->
      if canton.value == "none"
        $("#container svg g#cantons path[id='#{canton.name}']}").attr('fill', 'url(#gridPattern)')
      else
        if canton.value >= 0
          $("#container svg g#cantons path[id='#{canton.name}']}").attr('fill', "rgba(166,3,17,#{(canton.value / 100)})")
        else
          $("#container svg g#cantons path[id='#{canton.name}']}").attr('fill', "rgba(49,0,98,#{((canton.value * -1) / 100)})")
      
    (color_canton canton for canton in window.current_map.cantons)
  
  
  # **get\_highest\_value**
  #
  # Iterates over the canton array, grabs the property for the given key and outputs the one farest away from zero.
  get_highest_value = (key, canton_array) ->
    highest_stretched_value = 0
    is_higher = (canton) ->
      parsed_number = null
      if canton_array?
        parsed_number = parseFloat(canton[key])
      else
        parsed_number = parseFloat(window.swissmapdata.data[canton][key].value)
      
      if !isNaN(parsed_number) # check if it's a number
        if parsed_number >= 0 and parsed_number > highest_stretched_value
          highest_stretched_value = parsed_number
        else
          if parsed_number < 0 and (parsed_number * -1) > highest_stretched_value
            highest_stretched_value = (parsed_number * -1)
      else
        if canton_array?
          console.log("canton #{canton.canton} has no parseable value for the key: #{key}")
        else
          console.log("canton #{canton} has no parseable value for the key: #{key}")
        
    if canton_array?
      console.log(canton_array)
      (is_higher canton for canton in canton_array)
    else    
      (is_higher canton for own canton of window.swissmapdata.data)
    return highest_stretched_value

  # **stretch\_and\_apply\_single\_dataset**
  #
  # Convert the actual values to stretched percentage values
  stretch_and_apply_single_dataset = (key) ->
    highest_value = get_highest_value(key)
    cantons = []
    
    add_values_to_dataset = (canton_key) ->
      parsed_number = parseFloat(window.swissmapdata.data[canton_key][key].value)
      if !isNaN(parsed_number) # value is parseable
        percentage = (100 * parsed_number) / highest_value
        cantons.push({name: canton_key, value: percentage})
      else
        cantons.push({name: canton_key, value: 'none'})
    (add_values_to_dataset canton_key for own canton_key of window.swissmapdata.data)
    
    window.current_map.cantons = cantons
    window.current_map.type = 'single'
    window.current_map.key1 = key
    apply_calculations_to_map()
   
    
  # **stretch\_and\_apply\_combined\_dataset**
  #
  # Mashup the two datasets and then convert the actual values to stretched percentage values
  stretch_and_apply_combined_dataset = (key1, key2) ->
    combined_dataset = []
    divide_value = (canton) ->
      value1 = parseFloat(window.swissmapdata.data[canton][key1].value)
      value2 = parseFloat(window.swissmapdata.data[canton][key2].value)
      
      if !isNaN(value1) and !isNaN(value2) # both values are parseable
        combined_dataset.push({name: canton, value: (value1/value2)})
      else
        combined_dataset.push({name: canton, value: 'none'})
    (divide_value canton for own canton of window.swissmapdata.data)
    
    highest_value = get_highest_value('value', combined_dataset)
    
    cantons = []
    add_values_to_dataset = (canton) ->
      parsed_number = parseFloat(canton.value)
      if !isNaN(parsed_number) # value is parseable
        percentage = (100 * parsed_number) / highest_value
        cantons.push({name: canton.name, value: percentage})
      else
        cantons.push({name: canton.name, value: 'none'})
        
    (add_values_to_dataset canton for canton in combined_dataset)
    
    window.current_map.cantons = cantons
    window.current_map.type = 'double'
    window.current_map.key1 = key1
    window.current_map.key2 = key2
    apply_calculations_to_map()    
   
    
  # **set\_first\_dataset**
  #
  # Do all the necessary steps to render the first dataset on the switzerland map.
  set_first_dataset = (dataset_id, dataset_name) -> 
    if dataset_id?
      window.dataset1 = dataset_id
      if window.dataset2?
        console.log(window.dataset2)
        window.dataset1 = dataset_id
        $('#target1').html("<span>#{dataset_name}</span>")
        stretch_and_apply_combined_dataset(window.dataset1, window.dataset2)        
      else # only dataset1 present
        $('#target1').html("<span>#{dataset_name}</span>")
        stretch_and_apply_single_dataset(dataset_id)
    else
      warning_dataset_could_not_be_read()


  # **set\_second\_dataset**
  #
  # Do all the necessary steps to render the second dataset on the switzerland map.
  set_second_dataset = (dataset_id, dataset_name) ->
    if dataset_id?
      if !window.dataset1? # dataset1 == null
        set_first_dataset(dataset_id, dataset_name)
      else
        window.dataset2 = dataset_id
        $('#target2').html("<span>#{dataset_name}</span>")
        stretch_and_apply_combined_dataset(window.dataset1, window.dataset2)
    else
      warning_dataset_could_not_be_read()

  $("#target1").droppable(
    drop: (event, ui) ->
        key = $(ui.draggable).attr('id')
        name = $(ui.draggable).html()
        set_first_dataset(key, name)
  )
  
  $("#target2").droppable(
    drop: (event, ui) ->
        key = $(ui.draggable).attr('id')
        name = $(ui.draggable).html()
        set_second_dataset(key, name)
  )


  # Reset the datasets.
  $('#datasets ul.categories').html("")
  
  
  # Add the available datasets to the menu.
  $menu = $('#datasets .categories')
  add_dataset = (dataset_key) ->
    definition = window.swissmapdata.definitions[dataset_key]
    
    $category = $menu.find("li ##{definition.category_computer}")
    if $category.length == 0
      $menu.append("<li><span>#{definition.category_human}</span><ul class='datatypes' id='#{definition.category_computer}'></ul></li>")
      $category = $menu.find("li ##{definition.category_computer}")
  
    $category.append("<li id='#{definition.dataset_computer}'>#{definition.dataset_human}</li>")      
    
  (add_dataset dataset_key for own dataset_key of window.swissmapdata.definitions)


  # Hide all the datasets on load.
  $("#datasets .categories .datatypes").hide()


  # Hook up the on-click event to expand the datasets after a click on the category title.
  $("#datasets .categories li span").click(() ->
    $(this).next().toggle()
  )


  # Make the dataset draggable.
  $("#datasets .categories .datatypes li").draggable(revert: true)


  # Hook up the click events to the cantons to show additional information on click.
  $("#container svg g#cantons path").click(() ->
    # get the canton_id
    canton_id = $(this).attr('id')
    
    # get the full original canton object from window.swissmapdata.data
    canton = window.swissmapdata.data[canton_id]

    message = ""
    if window.current_map.type == "single"
      canton_map = get_canton_from_current_map_cantons(canton_id)
      message = "Original Value: #{canton[window.current_map.key1].value} #{window.swissmapdata.definitions[window.current_map.key1].dataset_unit}<br/>Relative Value: #{canton_map.value}%"
    else
      if window.current_map.type == "double"
        message = "Original Value Dataset 1: #{canton[window.current_map.key1].value} #{window.swissmapdata.definitions[window.current_map.key1].dataset_unit}<br/>"
        message += "Original Value Dataset 2: #{canton[window.current_map.key2].value} #{window.swissmapdata.definitions[window.current_map.key2].dataset_unit}<br/>"
        
        # make divison of original values
        mashup_value = parseFloat(canton[window.current_map.key1].value) / parseFloat(canton[window.current_map.key2].value)
        if !isNaN(mashup_value)
          message += "Mashed up value: #{mashup_value} #{window.swissmapdata.definitions[window.current_map.key1].dataset_unit} <b>/</b> #{window.swissmapdata.definitions[window.current_map.key2].dataset_unit}<br/>"
          canton_map = get_canton_from_current_map_cantons(canton_id)
          message += "Relative mashed up value: #{canton_map.value} %"
        else
          message += "Because of incomplete data we couldn't come up with a mashup value for #{canton_id}."
        
    $("<div><strong>Canton: #{canton_id}</strong><br/>#{message}</div>").dialog()
    # $("<div><strong>Canton:</strong> #{$(this).attr('id')}<br/><strong>Percentage:</strong> #{(parseFloat($(this).attr('fill').replace('rgba(166,3,17,','').replace(')','')) * 100)}%</div>").dialog()
  )
  
  
  # **fix\_webkit\_height\_bug**
  #
  # as reported on [stackoverflow.com](http://stackoverflow.com/questions/7570917/svg-height-incorrectly-calculated-in-webkit-browsers)
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