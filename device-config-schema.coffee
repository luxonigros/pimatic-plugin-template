module.exports = {
	title: "WifiSwitch device config schemas"
	WifiSocketSwitch: {
		title: "WifiSocketSwitch config options"
		type: "object"
		extensions: ["xlink", "xAttributeOptions"]
		properties:
			id:
				description: "The id of the device"
				type: "string"
			name:
				description: "The name of the device"
				type: "string"
			address:
				description: "The ip-address of the device"
				type: "string"
			port:
				description: "The port of the device"
				type: "number"
	}
}