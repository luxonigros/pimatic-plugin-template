# #my-plugin configuration options
# Declare your config option for your plugin here. 
module.exports = {
  title: "wifiswitch config options"
  type: "object"
  properties:
    port:
      description: "The port the UDP server listens on"
      type: "number"
      default: 3000
}