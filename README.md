pimatic-wifiswitch
=======================

Plugin for creating switches using the esp8266 based switches from [Sonoff](http://sonoff.itead.cc/en/products/residential/s20-socket).
Of course it is possible to program any device as long as it will understand below protocol.

For now this plugin only supports on/off commands by sending/receiving a '1' or '0'.
In the future it can be expanded by adding support for receiving sensor readings and dimmable lights.

Setup
-----------
You can load the plugin by editing your `config.json` to include:

```json
{
	"plugin": "wifiswitch"
}
```

Devices
----------

Devices can be added by either directly editing the config file or adding devices through the gui.

As of now, only 1 device is available: "WifiSocketSwitch".

##### Example config:

```json
{
	"id": "wifiswitchtest",
    "name": "wifiSwitchTest",
    "class": "WifiSocketSwitch",
	"port": 8888,   
    "address": "192.168.0.100"
}
```

Port:		This is the receiving port on the device itself to wich UDP command wil be send by this plugin.
Address:	This is the IP-Adress of the device.

The code for the switch itself wil be added later...