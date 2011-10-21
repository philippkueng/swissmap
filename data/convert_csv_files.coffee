sys = require('sys')
csv = require('csv')

datajs =
  definitions: {}
  data: {}

# get all *.csv files within this directory
fs = require('fs')
fs.readdir('./raw_data', (err, files) ->
  dataset_definition = {}
  dataset_data = []
  files_to_parse = files.length
  
  merge_local_with_master_datajs = () ->
    # check if dataset_definition name is unique
    key = dataset_definition.dataset_computer
    
    if !datajs.definitions[key]? # dataset name is not yet taken
      datajs.definitions[key] = dataset_definition
      add_canton_to_datajs = (item) ->
        if !datajs.data[item.canton]? # canton is not yet in datajs.data
          datajs.data[item.canton] = {}
        
        # insert value and metadata into canton paramater
        datajs.data[item.canton][key] =
          value: item.value
          metadata: item.value_metadata

      (add_canton_to_datajs item for item in dataset_data)

      # clear the local dataset
      dataset_definition = {}
      dataset_data = []
      
    else
      console.log("The Dataset Name #{dataset_definition.dataset_computer} is not unique, please change it. Conversion aborted.")
      process.exit()
      
  add_to_datajs = (data) -> # canton, value, value_metadata
    dataset_data.push((canton: data.canton, value: data.value, value_metadata: data.value_metadata))
    
  convert_to_computer_format = (string) ->
    string = string.toLowerCase() # make lowercase
    string = string.replace(/\W/gi, "_") # replace whitespace with underline
    return string
    
  parse_csv = (file, file_index) ->
    csv().fromPath("./raw_data/#{file}", {delimiter: ',', columns: true}).transform((data) ->
      return data
    ).on('data', (data, index) ->
      if data.value? and data.canton?
        
        # gather dataset metadata
        if index <= 9
          if data.metadata?
            switch index
              when 0 # category name in human format
                dataset_definition.category_human = data.metadata
                dataset_definition.category_computer = convert_to_computer_format(data.metadata)
              when 1 # dataset name in human format
                dataset_definition.dataset_human = data.metadata
                dataset_definition.dataset_computer = convert_to_computer_format(data.metadata)
              when 2 # dataset unit eg. People per Canton
                dataset_definition.dataset_unit = data.metadata
              when 3 # dataset origin eg. http://bfs.admin.ch/file-xy.html
                dataset_definition.dataset_origin = data.metadata
              when 4 # license used for dataset
                dataset_definition.dataset_license = data.metadata
              when 5 # source of license used for dataset
                dataset_definition.dataset_license_source = data.metadata
              when 6 # age of dataset eg. 2010 (only year number)
                dataset_definition.dataset_age = data.metadata
              when 7 # dataset scraped at. eg. 12. March 2011 (custom date allowed)
                dataset_definition.scraped_at = data.metadata
              when 8 # more information about datasource
                dataset_definition.more_information = data.metadata
              when 9 # value type addition eg. for percentage values
                dataset_definition.type = data.metadata
          else
            missing_metadata_type =
              field_0: "category name in human format"
              field_1: "dataset name in human format"
              field_2: "dataset unit eg. People per Canton"
              field_3: "dataset origin eg. http://bfs.admin.ch/file-xy.html"
              field_4: "license used for dataset"
              field_5: "source of license used for dataset"
              field_6: "age of dataset eg. 2010 (only year number)"
              field_7: "dataset scraped at. eg. 12. March 2011 (custom date allowed)"
              field_8: "more information about datasource"
              field_9: "value type addition eg. for percentage values"
              
            console.log("There's missing metadata information in the file #{file}. Field #{index} from the top should contain: #{missing_metadata_type["field_#{index}"]}")
            
        add_to_datajs(data)
      
    ).on('end', (count) ->
      # merge current data file with master data file
      merge_local_with_master_datajs()
      if files_to_parse == 1 # write datajs to disk
        fs.writeFile('data.js', "window.swissmapdata = #{JSON.stringify(datajs)};", (err) ->
          if err then throw err
          console.log("data.js written to disk")
        )
      else
        files_to_parse = files_to_parse - 1
      
      console.log("File #{file} converted successfully.")
      
      # check wether there are more files to convert
      if files? and (files.length - 1) > file_index
        parse_csv(files[file_index + 1], file_index + 1)
      
    ).on('error', (error) ->
      throw error
    )
    
  console.log("Recognized #{files.length} files which will be merged into one data.js file now.")
  if files? and files.length >= 1
    parse_csv(files[0], 0)
  else
    console.log("No CSV files found in the raw_data folder. Exiting.")
    process.exit()
)