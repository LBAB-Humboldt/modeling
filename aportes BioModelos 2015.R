#Consulta aportes primates
dbfile = "Z:/BioModelos/DB_current/01112016/production.sqlite3" # Assign the sqlite datbase and full path to a variable
sqlite = dbDriver("SQLite") # Instantiate the dbDriver to a convenient object
mydb = dbConnect(sqlite, dbfile) # Assign the connection string to a connection object

sp.list<-c("Alouatta seniculus", "Aotus lemurinus", "Aotus vociferans","Cacajao melanocephalus",
"Callicebus cupreus","Callicebus torquatus","Callithrix pygmaea","Cebus albifrons","Cebus apella",
"Cebus capucinus","Lagothrix lagotricha","Saguinus fuscicollis","Saguinus leucopus","Saimiri sciureus")

getBMScores<-function(species,con){
  scores.q <- paste0("SELECT s.sci_name AS Especie, m.description AS Umbral, m.level AS Nivel, u.name AS Experto, r.score AS Calificación, r.updated_at AS Fecha
  FROM species AS s
  JOIN models AS m ON s.id = m.species_id
  JOIN ratings AS r ON r.model_id = m.id
  JOIN users AS u ON u.id = r.user_id
  WHERE s.sci_name = \'", species,
  "\' ORDER BY s.sci_name")
  
  q.result <-dbSendQuery(con, scores.q)
  edits <- fetch(q.result)
  dbClearResult(q.result)
  return(edits)
}

scores<-data.frame()
for(i in 1:length(sp.list)){
  df<-getBMScores(sp.list[i], mydb)
  scores<-rbind(scores,df)
}
write.csv(scores,"scores.csv",row.names=FALSE)
