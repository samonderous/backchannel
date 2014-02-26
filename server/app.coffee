express = require('express')
BCModel = require("./BCModel").BCModel

app = express()

app.use express.bodyParser()
app.use express.logger()

app.get '/hello', (req, res)=>
  res.send 'Hello World'

app.get '/feed', (req, res)=>
  bcModel = new BCModel("hello",12123123,5,1)
  res.send (JSON.stringify bcModel)

app.listen(3001);
console.log('Listening on port 3001')