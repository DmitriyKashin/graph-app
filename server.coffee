express = require("express")

app = express.createServer(express.bodyParser())
app.listen 8080, "127.0.0.1"
 
app.get "/", (req, res) ->
    res.sendfile __dirname + "/project_1/index.html"
    


prices_set_int = []
classes_set_int = []
app.use(express.bodyParser())

app.post "/", (req, res) ->
  console.log(req.body.name)
  res.redirect('back')

app.get '/graphics', (req, res) ->
  console.log('get graphics')
  res.send(peopleServer)


app.post "/echo", (req, res) ->
    returnJsonObj =
        echoMessage: req.body.message
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify(returnJsonObj));

 xml2js = require 'xml2js'
 fs = require 'fs'


parser = new xml2js.Parser(xml2js.defaults["0.2"]);

fs.readFile __dirname + '/flystat_main.xml', (err, data) ->
  parser.parseString data, (err, result) ->

  	id_set = (muppet.id_field for muppet in result.DATA.ROW)
  	resources_set = (muppet.resource for muppet in result.DATA.ROW)	
  	classes_set = (muppet.class for muppet in result.DATA.ROW)
  	price_set = (muppet.price for muppet in result.DATA.ROW)
  	date_dep_set = (muppet.date_dep for muppet in result.DATA.ROW)
  	date_ret_set = (muppet.date_ret for muppet in result.DATA.ROW)
  	date_collect_set = (muppet.date_collect for muppet in result.DATA.ROW)
  	trans_company_set = (muppet.trans_company for muppet in result.DATA.ROW)
   
   count=0

   for obj in classes_set 
    if obj.toString() == 'E' then classes_set_int[count]=0
    if obj.toString() == 'B' then classes_set_int[count]=1
    if obj.toString() == 'W' then classes_set_int[count]=2
    count++

   count=0

   for obj in price_set
    prices_set_int[count]=parseInt(obj.toString())
    count++

peopleServer = [{id: 1, firstName: "John", lastName: "Doe"}, {id: 2, firstName: "Marta", lastName: "Moe"}, {id: 3, firstName: "Robert", lastName: "Roe"}]
ordinate_set = [{id:1, x: 'prices_set_int', y: 'classes_set_int' }]
          
        

  
  			
  	
   		
  

  	
    
