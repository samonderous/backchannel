express = require('express')
#JSON = require('json')

app = express()

app.use express.bodyParser()
app.use express.logger()

app.get '/hello', (req, res)=>
  res.send 'Hello World'

app.get '/feed', (req, res)=>
  res.send (JSON.stringify { status: "success", elements: [{text: "hello", time:"1323423423", agrees:4, disagrees:1},{text: "hello", time:"1323423423", agrees:4, disagrees:1},{text: "hello", time:"1323423423", agrees:4, disagrees:1}] })

app.listen(3001);
console.log('Listening on port 3001')