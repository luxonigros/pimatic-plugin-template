# #Plugin template

# This is an plugin template and mini tutorial for creating pimatic plugins. It will explain the 
# basics of how the plugin system works and how a plugin should look like.

# ##The plugin code

# Your plugin must export a single function, that takes one argument and returns a instance of
# your plugin class. The parameter is an envirement object containing all pimatic related functions
# and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
module.exports = (env) ->

  # ###require modules included in pimatic
  # To require modules that are included in pimatic use `env.require`. For available packages take 
  # a look at the dependencies section in pimatics package.json

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the dgram library
  server = require('dgram').createSocket "udp4"

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  # Include you own depencies with nodes global require function:
  #  
  #  

  # ###WifiSwitch class
  # Create a class that extends the Plugin class and implements the following functions:
  class WifiSwitch extends env.plugins.Plugin

    # ####init()
    # The `init` function is called by the framework to ask your plugin to initialise.
    #  
    # #####params:
    #  * `app` is the [express] instance the framework is using.
    #  * `framework` the framework itself
    #  * `config` the properties the user specified as config for your plugin in the `plugins` 
    #     section of the config.json file 
    #     
    # 
    init: (app, @framework, @config) =>
      @port = @config.port
      @addedDevices = []

      deviceConfigDef = require("./device-config-schema")
      @framework.deviceManager.registerDeviceClass("WifiSocketSwitch", {
        configDef: deviceConfigDef["WifiSocketSwitch"]
        createCallback: (config, lastState) =>
          device = new WifiSocketSwitch(config, @, lastState)
          @addedDevices.push device
          return device
      })

      env.logger.debug("devices " + @addedDevices.length) 

      @createServer()

    removeWifiSwitchDevice: (wifiDevice) ->
      for device, index in @addedDevices
        if wifiDevice.id is device.id
          @addedDevices.splice index, 1
          env.logger.debug("Removed #{device.id}, devices left: #{@addedDevices.length}")

    createServer: ->     
      server.on "message", @msgCallback.bind(this)

      server.on "listening", ->
        address = server.address()
        env.logger.info("Listening for UDP-request on port " + address.port + "...")

      server.bind @port

    pushCommand: (address, port, cmd) ->
      env.logger.debug("Send cmd: " + cmd + " to: " + address + ":" + port)
      switch cmd
        when "on"
          msg = '1'
          server.send(msg, 0, msg.length, port, address)
        when "off"
          msg = '0'
          server.send(msg, 0, msg.length, port, address)

    msgCallback: (msg, rinfo) ->
      env.logger.debug("Message from " + rinfo.address + ":" + rinfo.port + ": " + msg)
      for dev in @addedDevices
        dev.eventHandler msg.toString(), rinfo.address

  class WifiSocketSwitch extends env.devices.PowerSwitch

    attributes:
      state:
        description: "The current state of the switch"
        type: "boolean"
        labels: ['on', 'off']

    constructor: (@config, @plugin, lastState) ->
      @name = @config.name
      @id = @config.id
      @address = @config.address
      @port = @config.port

      super()

    destroy: ->
      WifiSwitch.removeWifiSwitchDevice @
      super()

    eventHandler: (msg, address) ->
      if address is @address
        switch msg
          when "1" then @changeStateTo true
          when "0" then @changeStateTo false

    changeStateTo: (state) ->
      if @_state is state
        return Promise.resolve true
      else 
        env.logger.info("Switching " + (if state is true then "on" else "off") + "...")
        return Promise.try( =>
        @_setState state
        if state is true
          WifiSwitch.pushCommand(@address, @port, "on")
        else
          WifiSwitch.pushCommand(@address, @port, "off")   
      )

  # ###Finally
  # Create a instance of wifiswitch
  WifiSwitch = new WifiSwitch
  # and return it to the framework.
  return WifiSwitch