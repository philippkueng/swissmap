# merge the csv files into the data.js file
node ./node_modules/coffee-script/bin/coffee --compile data/*.coffee
cd data/
node convert_csv_files.js
cd ..

# compile the coffeescript code to javascript
node ./node_modules/coffee-script/bin/coffee --compile js/*.coffee
