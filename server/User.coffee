Sequelize = require('sequelize')

class User
	constructor: (@email,@hashedEmail,@hashedUDID,@hashedEmailAndUDID)->
 		@confirmed = false;
 	
 	confirmed: ()->
 		@confirmed = true;

module.exports = User
