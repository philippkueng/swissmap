#SwissMap

## Getting it running

Until now SwissMap only consists of a static html page, however since parts of the Javascript for the browser is are written in CoffeeScript compilation is necessary before you can deploy it on your server. To do that follow the recipe below, which was written for Ubuntu 10.04 LTS.

**Install Node.js**

  $ sudo apt-get install g++ gcc openssl libssl-dev git-core -y
  $ cd /your/home/directory
  $ git clone git://github.com/joyent/node.git
  $ cd node/
  $ ./configure
  $ sudo make
  $ sudo make install
  
**Install Node Packet Manager (NPM)**
 
 $ cd /your/home/directory
 $ git clone git://github.com/isaacs/npm.git
 $ cd npm/
 $ sudo make install
 
**Install CoffeeScript**

  $ sudo npm install coffee-script -g
  
**Cloning SwissMap**

  $ cd /your/home/directory
  $ git clone git://github.com/philippkueng/swissmap.git
  
**Compiling CoffeeScript files**

  $ cd swissmap/js
  $ coffee --compile *.coffee
  
**Done**

Now open 'index.html' with your browser or put this folder onto your server to serve it to the public.

## What is SwissMap?

SwissMap was initiated at Make.OpenData.ch @ EPFL by the contributors below with the goal to enable people make sense out of public data by comparing it against each other and making it visible on a swiss map.

## Contributors

* [Florin Iorganda](http://twitter.com/#!/florin_iorganda)
* [Frederic Jacobs](https://github.com/FredericJacobs)
* [Philipp Küng](https://github.com/philippkueng)
* Maybe you?

## Got Data?, Development Skills? or just too much time?

Get in contact with us via twitter ([@florin_iorganda](http://twitter.com/#!/florin_iorganda), [@fredericjacobs](http://twitter.com/#!/fredericjacobs) or [@philippkueng](http://twitter.com/#!/philippkueng)) or send us an email to [swissmap@bitfondue.com](mailto:swissmap@bitfondue.com) with a description of the data you'd like to contribute or the skills you'd like to lend to the SwissMap project. If you just have too much time but not necessarily programming skills, then create a github account, fork this repository and help improve our documentation.
  
## License

SwissMap is licensed under the [CC BY-SA 3.0 - CreativeCommons Attribution-ShareAlike 3.0 License](http://creativecommons.org/licenses/by-sa/3.0/)
