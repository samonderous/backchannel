Sequelize = require('sequelize')

s4 = ()->
	return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);

guid = ()->
	return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
	
class BCModel
	constructor: (@text,@time,@agrees,@disagrees)->
 		@uuid = guid();
 	
module.exports = BCModel
