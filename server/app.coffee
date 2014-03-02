express = require('express')
BCModel = require("./BCModel")
User = require("./User")
Sequelize = require('sequelize')
global.config = require('./config/default')

#db stuff
db = config.db
global.sequelize = new Sequelize db.name, db.user, db.pass, db.options

masterFeed = []
usersTable = []

findBCModelInFeed = (array,uuid)->
	for bc in array 
		console.log (uuid + ", " + bc.uuid)
		if uuid == bc.uuid
			return bc
	return null

confirmUserFromHash = (hash,array)->
	for user in array
		if (user.hashedEmailAndUDID == hash) 
			user.confirmed
			return true;
	return false;

app = express()
app.use express.bodyParser()
app.use express.logger()

app.use app.router

app.get '/hello', (req, res)=>
	res.send 'Hello World'

app.get '/feed', (req, res)=>
	res.send (masterFeed)

app.get '/users', (req, res)=>
	res.send (usersTable)

app.put '/register', (req, res)=>
	console.log(req.body.email)
	console.log(req.body.hashedEmail)
	console.log(req.body.hashedUDID)
	console.log(req.body.hashedEmailAndUDID)
	user = new User(req.body.email, req.body.hashedEmail, req.body.hashedUDID, req.body.hashedEmailAndUDID)
	usersTable.push user
	#if req.body.hashedEmail
	res.send ("{hashedEmailAndUDID : " + req.body.hashedEmailAndUDID + "}")

app.put '/confirm/:hashedEmailAndUDID', (req,res)=>
	console.log(req.param("hashedEmailAndUDID"))
	if (confirmUserFromHash(req.param("hashedEmailAndUDID"),usersTable))
		res.send (JSON.stringify {
			confirmed: true
		})
	else
		res.send (JSON.stringify {
			confirmed: false
		})

app.post '/login', (req, res)=>


app.put '/compose', (req, res)=>
	console.log(req.body)
	composedBC = new BCModel((req.body.text), new Date().getTime(), 0, 0)
	console.log( composedBC.uuid )
	masterFeed.push composedBC
	console.log (masterFeed.length )
	res.send (JSON.stringify {
			uuid: composedBC.uuid
		})

app.put '/agree', (req, res)=>
	console.log(req.body)
	bcModel = findBCModelInFeed masterFeed,(req.param "uuid")
	if bcModel == null 
		res.send ("{}")
	else
		bcModel.agrees += 1
		console.log(masterFeed)
		res.send (bcModel)

app.put '/disagree', (req, res)=>
	console.log(req.body)
	bcModel = findBCModelInFeed masterFeed,(req.param "uuid")
	if bcModel == null 
		res.send ("{}")
	else
		bcModel.disagrees += 1
		console.log(masterFeed)
		res.send (bcModel)

app.listen(3001);
console.log('Listening on port 3001')