express = require("express")
_ = require("underscore")
fs = require("fs")
connect= require("connect")
seq = 2              # Количество объектов, которые сервер отсылает изначально (graphicServer)
clock_set_int = []   # Время : 00-04  - 0 , 04-08 -1, 08-12  - 2, 12-16  -3 , 16-20 -4, 20-24 -5 
prices_set_int = []  # Цены
classes_set_int = [] # Классы 0-E, 1-B, 2-W
days_set_int = [] 
days_to_fly_set =[]  # 0-Sun, 1-Mon, 2-Tue, 3-Wen, 4-Thu, 5- Fri, 6-Sat
row_count = 0        # Количество записей в нашем XML
data_x = []          # Элементы  создания  dataSet  для рисовки посредством jFlot
data_y = []          #
users_session = {}   # двумерный массив вида [user_id, sessionID]
userID=1             # Счетчик пользователей
charge=1             # Заглушка на первую сессию (При втором обновлении окна после действий пользователя sessionID меняется)
current_user = null  # Текущий пользователь
OldSession = null    # sessionID предыдущего запроса


i=0

session_graphicServer = []







app = express()
app.listen 3000
app.use express.static(__dirname)

store = new express.session.MemoryStore;

app.use express.cookieParser()
app.use(express.session({ secret: 'whatever', store: store }))


app.configure ->
  app.use express.methodOverride()
  app.use express.bodyParser()
  app.use app.router
  app.set "view options",
    layout: false

  app.engine "html", require("ejs").renderFile

app.get "/", (req, res) ->

  res.render "index.html"


  

app.all "*", (req, res, next) ->
  res.header "Access-Control-Allow-Origin", "*"
  res.header "Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS"
  res.header "Access-Control-Allow-Headers", "X-Requested-With, Content-Type"
  next()

app.get "/graphics", (req, res) ->
  console.log "get graphics list"
  
  

  user_id = users_session[req.sessionID]
  

  if user_id? 

      console.log 'The user has returned : ' + user_id
   
      
  else
      users_session[req.sessionID]=userID
      
      console.log 'New user here : ' + userID
      userID++
      user_id = userID
 
  charge++

 
  current_user = user_id
    
 
  if charge is 2 then current_user = 1  # Заглушка на первую загрузку
 
 
  console.log "current user : " + current_user
  res.send session_graphicServer[current_user] # Отправляем данные для нашего пользователя

app.get "/graphics/:id", (req, res) ->

  user_id = users_session[req.sessionID]
  

  if user_id? 

      console.log(' This user has returned : ') + user_id
   
      
  else
      users_session[req.sessionID]=userID
      
      console.log 'New user here : ' + userID
      
      user_id = userID
      userID++

  current_user = user_id

  graphic_rep = null

  console.log "get graphic: " + req.params.id

  graphic = _.find session_graphicServer[current_user], (p) ->
    if parseInt(p.id) is parseInt(req.params.id) then  graphic_rep=p
  
  console.log graphic_rep
  

  res.send graphic_rep

app.delete "/graphics/:id", (req, res) ->

  user_id = users_session[req.sessionID]
  

  if user_id? 

      console.log 'This user has returned : ' + user_id
   
      
  else
      users_session[req.sessionID]=userID
      
      console.log 'New user here : ' + userID
      
      user_id = userID
      userID++

  current_user = user_id

  
  console.log "delete graphic: " + req.params.id
  count = 0
  i = 0
  check =0
 
  
  

  for obj in session_graphicServer[current_user]
     count++
  
  while i < count
    console.log session_graphicServer[current_user][i].id
    console.log req.params.id 
    if parseInt(session_graphicServer[current_user][i].id) == parseInt(req.params.id) then session_graphicServer[current_user].splice(i,1)       
    i++   
  res.send session_graphicServer[current_user]
       
     
        
  

app.post "/graphics", (req, res) ->


  user_id = users_session[req.sessionID]
  

  if user_id? 

      console.log 'This user has returned : '+ user_id
   
      
  else
      users_session[req.sessionID]=userID
      
      console.log 'New user here : ' + userID
      
      user_id = userID
      userID++

  current_user = user_id

  console.log "new graphic:  " + JSON.stringify(req.body) + "for user" + current_user
  graphic = req.body
  graphic.dataSet=[]
  getNextId = ->
    ++seq

  switch graphic.x_type
    when "price" then data_x = prices_set_int
    when "class" then data_x = classes_set_int
    when "days_to_fly" then data_x = days_to_fly_set
    when "time_of_fly" then data_x = clock_set_int
    when "day_of_week" then data_x = days_set_int 
  
  switch graphic.y_type
    when "price" then data_y = prices_set_int
    when "class" then data_y = classes_set_int
    when "days_to_fly" then data_y = days_to_fly_set
    when "time_of_fly" then data_y = clock_set_int
    when "day_of_week" then data_y = days_set_int  
  i = 0
  

  while i < row_count 
      graphic.dataSet.push([data_y[i], data_x[i]])
      i++

  
  
  
  graphic.id = getNextId()
  

  if session_graphicServer[current_user]?
    
    session_graphicServer[current_user].push(graphic)
   
  else

   session_graphicServer[current_user] = [graphic]

  

  
  
  
  res.send session_graphicServer[current_user]

app.put "/graphics/:id", (req, res) ->


  user_id = users_session[req.sessionID]
  

  if user_id? 

      console.log 'This user has returned : ' + user_id
   
      
  else
      users_session[req.sessionID]=userID
      
      console.log 'New user here : ' + userID
      
      user_id = userID
      userID++

  current_user = user_id 


  console.log "change graphic  : " + JSON.stringify(req.body)
  count = 0
  
  
  
  switch req.body.x_type
    when "price" then data_x = prices_set_int
    when "class" then data_x = classes_set_int
    when "days_to_fly" then data_x = days_to_fly_set
    when "time_of_fly" then data_x = clock_set_int
    when "day_of_week" then data_x = days_set_int 

  switch req.body.y_type
    when "price" then data_y = prices_set_int
    when "class" then data_y = classes_set_int
    when "days_to_fly" then data_y = days_to_fly_set
    when "time_of_fly" then data_y = clock_set_int
    when "day_of_week" then data_y = days_set_int 

  for obj in session_graphicServer[current_user]
     count++
  i = 0

  while i < count
    if parseInt(session_graphicServer[current_user][i].id) == parseInt(req.params.id)
     session_graphicServer[current_user][i].x_type = req.body.x_type
     session_graphicServer[current_user][i].y_type = req.body.y_type
     session_graphicServer[current_user][i].dataSet=[]
     k=0
     while k < row_count 
      session_graphicServer[current_user][i].dataSet .push([data_y[k], data_x[k]])
      k++
      
    i++

  res.send session_graphicServer[current_user]



xml2js = require 'xml2js'
fs = require 'fs'



parser = new xml2js.Parser(xml2js.defaults["0.2"])

 

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
    clock = parseInt(date_dep_set[50].toString()[11]+date_dep_set[50].toString()[12])
    
    
    for obj in classes_set 
     classes_set_int[count]=0 if obj.toString() is 'E' 
     classes_set_int[count]=1 if obj.toString() is 'B'
     classes_set_int[count]=2 if obj.toString() is 'W'
     count++

    row_count=count
    count=0

    for obj in price_set
     prices_set_int[count]=parseInt(obj.toString())
     count++

    count=0 

    for obj in date_dep_set
      current_day = ["SUN", "MON", "TUE", "WEN", "THU", "FRI", "SAT"][new Date(date_dep_set[count][0]).getDay()]
      days_to_fly_set[count] = new Date(date_dep_set[count][0]).getDate()  -  new Date(date_collect_set[count][0]).getDate()
      days_set_int[count]=0 if current_day is "SUN"
      days_set_int[count]=1 if current_day is "MON"
      days_set_int[count]=2 if current_day is "TUE"
      days_set_int[count]=3 if current_day is "WEN"
      days_set_int[count]=4 if current_day is "THU"
      days_set_int[count]=5 if current_day is "FRI"
      days_set_int[count]=6 if current_day is "SAT"
      time_hour = parseInt(date_dep_set[count].toString()[11]+date_dep_set[count].toString()[12])
      clock_set_int[count] = 0 if time_hour>=0 and   time_hour<4
      clock_set_int[count] = 1 if time_hour>=4 and   time_hour<8
      clock_set_int[count] = 2 if time_hour>=8 and   time_hour<12
      clock_set_int[count] = 3 if time_hour>=12 and   time_hour<16
      clock_set_int[count] = 4 if time_hour>=16 and   time_hour<20
      clock_set_int[count] = 5 if time_hour>=20 and   time_hour<24    
      count++
    count=0
    
    

      
    
    
    








 


