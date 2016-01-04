files=list.files("U:/Modelos/06082014",pattern=".RData")
spNames<-gsub(".RData","",files)
in.Table<-data.frame(id=1:length(spNames),
nombre=spNames,
genero=sapply(strsplit(spNames," "),"[[",1),
epiteto_especifico=sapply(strsplit(spNames," "),"[[",2))

library(RMySQL)
con <- dbConnect(dbDriver("MySQL"), user = "root",password="root",dbname = "col2012ac",host="localhost")
cofTable2<-nameValidation(con,in.Table)

countRows<-function(inFile){
  inTable<-read.csv(inFile)
  return(nrow(inTable))
}

nrecs<-sapply(paste0("U:/Modelos/06082014/CSV/",spNames,".csv"), 
              countRows)

formato<-data.frame(Especie=spNames,
           "Número Registros"= nrecs,
           Familia=cofTable2$familia_CoL,
           Orden=cofTable2$orden_CoL,
           Clase=cofTable2$clase_CoL,
           Phyllum=cofTable2$phylum_CoL,
           Reino=cofTable2$reino_CoL)

write.csv(formato,"U:/Modelos/formatoSubida_06082014.csv",row.names=FALSE)

rm(list=ls())

#formato acuaticas
files=list.files("C:/Modelos/Acuaticas/Modelos4",pattern=".RData")
spNames<-gsub(".RData","",files)
in.Table<-data.frame(id=1:length(spNames),
                     nombre=spNames,
                     genero=sapply(strsplit(spNames,"_"),"[[",1),
                     epiteto_especifico=sapply(strsplit(spNames,"_"),"[[",2))

con <- dbConnect(dbDriver("MySQL"), user = "root",password="root",dbname = "col2012ac",host="localhost")
cofTable2<-nameValidation(con,in.Table)

countRows<-function(inFile){
  inTable<-read.csv(inFile)
  return(nrow(inTable))
}

nrecs<-sapply(paste0("C:/Modelos/Acuaticas/Modelos4/CSV/",spNames,".csv"), 
              countRows)

formato<-data.frame(Especie=spNames,
                    "Número Registros"= nrecs,
                    Familia=cofTable2$familia_CoL,
                    Orden=cofTable2$orden_CoL,
                    Clase=cofTable2$clase_CoL,
                    Phyllum=cofTable2$phylum_CoL,
                    Reino=cofTable2$reino_CoL)

write.csv(formato,"U:/Modelos/formatoSubida_acuaticas2.csv",row.names=FALSE)

# formato invasoras
files=list.files("U:/Modelos/invasoras",pattern=".RData")
files<-files[-37]
spNames<-gsub(".RData","",files)
in.Table<-data.frame(id=1:length(spNames),
                     nombre=spNames,
                     genero=sapply(strsplit(spNames," "),"[[",1),
                     epiteto_especifico=sapply(strsplit(spNames," "),"[[",2))

con <- dbConnect(dbDriver("MySQL"), user = "root",password="root",dbname = "col2012ac",host="localhost")
cofTable2<-nameValidation(con,in.Table)

nrecs<-sapply(paste0("U:/Modelos/invasoras/CSV/",spNames,".csv"), 
              countRows)

formato<-data.frame(Especie=spNames,
                    "Número Registros"= nrecs,
                    Familia=cofTable2$familia_CoL,
                    Orden=cofTable2$orden_CoL,
                    Clase=cofTable2$clase_CoL,
                    Phyllum=cofTable2$phylum_CoL,
                    Reino=cofTable2$reino_CoL)

write.csv(formato,"U:/Modelos/formatoSubida_invasoras.csv",
          row.names=FALSE)
