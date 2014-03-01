Sequelize = require('sequelize')
	
s4 = ()->
	return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);

guid = ()->
	return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();

class User
	constructor: (@email,@hashedEmail,@hashedUDID,@hashedEmailAndUDID)->
 		@confirmed = false;
 		@verifyKey = guid()
 	
 	confirmWith: (key)->
 		if (key == @verifyKey)
 			@confirmed = true;
 			return true;
 		else 
 			@confirmed = false;
 			return false;

module.exports = User
