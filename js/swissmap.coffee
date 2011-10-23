$(document).ready(() ->

  # Global Variables
  window.dataset1 = null
  window.dataset2 = null
  window.current_map =
    type: null
    cantons: []
    key1: null
    key2: null
    selected_canton: null
    canton_name_set: false
    single_dataset_set: false
    double_dataset_set: false
    
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
  
    
  # **add\_information\_original\_data**
  #
  # Render message and add the original numbers onto the website
  add_information_original_data = () ->
    message = ""
    
    create_single_message = () ->
      # check if first value is parseable
      raw_value1 = window.swissmapdata.data[window.current_map.selected_canton][window.current_map.key1].value
      unit_value1 = window.swissmapdata.definitions[window.current_map.key1].dataset_unit
      value1 = parseFloat(raw_value1)
      if !isNaN(value1)
        if window.swissmapdata.definitions[window.current_map.key1].type == "percentage"
          message = "<strong>#{(value1 * 100).toPrecision(4)}%</strong> #{unit_value1}"
        else
          message = "<strong>#{raw_value1}</strong> #{unit_value1}"
      else
        message = "There's no data available for canton <strong>#{window.cantons[window.current_map.selected_canton].english}</strong>"
        
    create_double_message = () ->

      # check if first value is parseable
      raw_value1 = window.swissmapdata.data[window.current_map.selected_canton][window.current_map.key1].value
      unit_value1 = window.swissmapdata.definitions[window.current_map.key1].dataset_unit
      value1 = parseFloat(raw_value1)
      
      # check if second value is parseable
      raw_value2 = window.swissmapdata.data[window.current_map.selected_canton][window.current_map.key2].value
      unit_value2 = window.swissmapdata.definitions[window.current_map.key2].dataset_unit
      value2 = parseFloat(raw_value2)
      
      if !isNaN(value1) and !isNaN(value2) # both values are valid
        type1 = window.swissmapdata.definitions[window.current_map.key1].type
        type2 = window.swissmapdata.definitions[window.current_map.key2].type
        
        if type1 == "percentage" and type2 == "percentage"
          message = "<strong>#{(value1 * 100).toPrecision(4)}%</strong> #{unit_value1}<br/><strong>divided by</strong><br/><strong>#{(value2 * 100).toPrecision(4)}%</strong> #{unit_value2}<br/><strong>equals</strong><h4>#{(value1 * 100) / (value2 * 100)}</h4>"
        else
          if type1 == "percentage" # type2 is absolute
            message = "<strong>#{(value1 * 100).toPrecision(4)}%</strong> #{unit_value1}<br/><strong>divided by</strong><br/><strong>#{raw_value2}</strong> #{unit_value2}<br/><strong>equals</strong><h4>#{(value1 * 100) / value2}</h4>"
          else
            if type2 == "percentage" # type1 is absolute
              message = "<strong>#{raw_value1}</strong> #{unit_value1}<br/><strong>divided by</strong><br/><strong>#{(value2 * 100).toPrecision(4)}%</strong> #{unit_value2}<br/><strong>equals</strong><h4>#{value1 / (value2 * 100)}</h4>"
            else # both values are absolute
              message = "<strong>#{raw_value1}</strong> #{unit_value1}<br/><strong>divided by</strong><br/><strong>#{raw_value1}</strong> #{unit_value2}<br/><strong>equals</strong><h4>#{value1 / value2}</h4>"
      else
        if !isNaN(value1) # value1 is valid
          if window.swissmapdata.definitions[window.current_map.key1].type == "percentage"
            message = "<strong>#{(value1 * 100).toPrecision(4)}%</strong> #{unit_value1}<br/>There's no data available for canton <strong>#{window.cantons[window.current_map.selected_canton].english}</strong> and dataset <strong>#{window.swissmapdata.definitions[window.current_map.key2].dataset_human}</strong>"
          else
            message = "<strong>#{raw_value1}</strong> #{unit_value1}<br/>There's no data available for canton <strong>#{window.cantons[window.current_map.selected_canton].english}</strong> and dataset <strong>#{window.swissmapdata.definitions[window.current_map.key2].dataset_human}</strong>"
        else
          if !isNaN(value2) # value2 is valid => value1 has to be invalid
            if window.swissmapdata.definitions[window.current_map.key2].type == "percentage"
              message = "<strong>#{(value2 * 100).toPrecision(4)}</strong> #{unit_value2}<br/>There's no data available for canton <strong>#{window.cantons[window.current_map.selected_canton].english}</strong> and dataset <strong>#{window.swissmapdata.definitions[window.current_map.key1].dataset_human}</strong>"
            else
              message = "<strong>#{raw_value2}</strong> #{unit_value2}<br/>There's no data available for canton <strong>#{window.cantons[window.current_map.selected_canton].english}</strong> and dataset <strong>#{window.swissmapdata.definitions[window.current_map.key1].dataset_human}</strong>"
          else
            message = "There's no data at all available for canton <strong>#{window.cantons[window.current_map.selected_canton].english}</strong> with the selected datasets"
    
    switch window.current_map.type
      when 'single' then create_single_message()
      when 'double' then create_double_message()
    
    if window.current_map.canton_name_set
      $('#canton_name').html(message)
    else
      window.current_map.canton_name_set = true
      $("<div id='canton_name' class='span10 alert-message block-message success'>#{message}</div>").appendTo('#information')
  
  
  # **create\_dataset\_information\_string**
  #
  # Create message for dataset information
  create_dataset_information_string = (key) ->
    # dataset name, form url, license, age, parsed, (contributed by)
    message = "<h5>#{window.swissmapdata.definitions[key].dataset_human}</h5><p>"
    
    # if from field available
    if window.swissmapdata.definitions[key].dataset_origin
      message = "#{message}<strong>From: </strong> <a href='#{window.swissmapdata.definitions[key].dataset_origin}'>here</a><br/>"
    
    # if license field available
    if window.swissmapdata.definitions[key].dataset_license
      # if license url field available
      if window.swissmapdata.definitions[key].dataset_license_source
        message = "#{message}<strong>License: </strong> <a href='#{window.swissmapdata.definitions[key].dataset_license_source}'>#{window.swissmapdata.definitions[key].dataset_license}</a><br/>"
      else
        message = "#{message}<strong>License: </strong> #{window.swissmapdata.definitions[key].dataset_license}<br/>"
    
    # if age field is found
    if window.swissmapdata.definitions[key].dataset_age
      message = "#{message}<strong>Dataset age: </strong> #{window.swissmapdata.definitions[key].dataset_age}<br/>"
    
    # if scraped_at field is found
    if window.swissmapdata.definitions[key].scraped_at
      message = "#{message}<strong>Scraped at: </strong> #{window.swissmapdata.definitions[key].scraped_at}<br/>"
  
    # if more_information field is found
    if window.swissmapdata.definitions[key].more_information
      message = "#{message}<br/><strong>More information:</strong><br/> #{window.swissmapdata.definitions[key].more_information}<br/>"
  
    return message
  
  # **add\_information\_single\_dataset**
  #
  # Add information for the first dataset onto the website
  add_information_single_dataset = () ->
    add_information_original_data()
    
    if window.current_map.single_dataset_set
      $('#info_dataset1').html(create_dataset_information_string(window.current_map.key1))
    else
      window.current_map.single_dataset_set = true
      $("<div id='info_dataset1' class='span5'>#{create_dataset_information_string(window.current_map.key1)}</div>").appendTo('#information')
  
  
  # **add\_information\_double\_dataset**
  #
  # Add information for the second dataset onto the website
  add_information_double_dataset = () ->
    add_information_single_dataset()
  
    if window.current_map.double_dataset_set
      $('#info_dataset2').html(create_dataset_information_string(window.current_map.key2))
    else
      window.current_map.double_dataset_set = true
      $("<div id='info_dataset2' class='span5'>#{create_dataset_information_string(window.current_map.key2)}</div>").appendTo('#information')
        
  
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
        $('#target1').html("<span class='alert-message block-message success'>#{dataset_name}</span>")
        stretch_and_apply_combined_dataset(window.dataset1, window.dataset2)        
      else # only dataset1 present
        $('#target1').html("<span class='alert-message block-message success'>#{dataset_name}</span>")
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
        $('#target2').html("<span class='alert-message block-message success'>#{dataset_name}</span>")
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
      $menu.append("<li><h4>#{definition.category_human}</h4><ul class='datatypes' id='#{definition.category_computer}'></ul></li>")
      $category = $menu.find("li ##{definition.category_computer}")
  
    $category.append("<li class='btn' id='#{definition.dataset_computer}'>#{definition.dataset_human}</li>")      
    
  (add_dataset dataset_key for own dataset_key of window.swissmapdata.definitions)


  # # Hide all the datasets on load.
  # $("#datasets .categories .datatypes").hide()
  # 
  # 
  # # Hook up the on-click event to expand the datasets after a click on the category title.
  # $("#datasets .categories li h4").click(() ->
  #   $(this).next().toggle()
  # )


  # Make the dataset draggable.
  $("#datasets .categories .datatypes li").draggable(revert: true)
  
  # Add the data for the popover to the SVG map
  add_popover_info_to_map = (canton_id) ->
    $path = $("div#container div#map svg#svg2 g#cantons path##{canton_id}")
    $path.attr('data-content', "<div style='width: 100%; overflow: auto;'><img src='css/images/#{canton_id}.png' style='width: 40px; float: left;'/><p style='float: left; margin-left: 20px;'><strong>Part of CH since:</strong> #{window.cantons[canton_id].since}<br/><strong>Population: </strong>#{window.swissmapdata.data[canton_id].total_population.value} ppl/canton</p></div>")
    $path.attr('data-original-title', window.cantons[canton_id].english)
    $path.attr('rel', 'popover')
  
  (add_popover_info_to_map canton for own canton of window.cantons)


  # Add the dataset metadata information to the #information field
  window.display_information = (canton_id) ->
    # check if one or two datasets are on the map
    window.current_map.selected_canton = canton_id
    switch window.current_map.type
      when 'double' then add_information_double_dataset()
      when 'single' then add_information_single_dataset()
  
  
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