library(reshape2)
library(R.utils)
library(plyr)
library(raster)
library(xlsx)
library(raster)

#Select species to evaluate
sp.oi<-read.xlsx("G:/Acuaticas/TallerBogota/ListaEspecies.xlsx",1,stringsAsFactors=F)

#prepare for taxonomic validation
spTable<-function(species,delim){
  #Args:
  # species: vector of scientific names to validate
  # delim: delimiter used to separate genus from specific epiteth in species vector
  #        E.g. "_" or " ".
  #Returns:
  # A data.frame to be passed to function nameValidation
  
  genus<-sapply(species,function(x) strsplit(x,delim)[[1]][1],USE.NAMES=FALSE)
  spp<-sapply(species,function(x) strsplit(x,delim)[[1]][2],USE.NAMES=FALSE)
  nombre=paste(genus,spp) 
  return(data.frame(id=1:length(species),nombre=nombre,genero=genus,epiteto_especifico=spp))
}

source("C:/Users/aves/Documents/GitHub/dataDownload/nameValidation.R")
library(RMySQL)
con <- dbConnect(dbDriver("MySQL"), user = "root",password="root",dbname = "col2012ac",host="localhost") #Cambie este comando ingresando el nombre de usuario y password asociado con su instalaci???n de MySQL
cofTable <- spTable(sp.oi$Nombre, " ")
sp.list.valid <- nameValidation(con, cofTable)

sp.list<-paste0(sp.list.valid$genero_aceptado," ",sp.list.valid$epiteto_aceptado)
sp.list2<-paste0(sp.list.valid$genero_aceptado,"_",sp.list.valid$epiteto_aceptado)

records=vector()
for(i in 1:length(sp.list2)){
  a<-tryCatch(read.csv(paste0("G:/Acuaticas/Modelos4/",sp.list2[i],".csv"),as.is=T),
           warning=function(w){
             data.frame()
             })
  records[i]<-nrow(a)
}

df<-data.frame(Nombre=sp.list, Familia=sp.list.valid$familia_CoL,CLase=sp.list.valid$clase_CoL,
               Reino=sp.list.valid$reino_CoL,Registros=records)
write.csv(df,"G:/Acuaticas/formato_subida.csv",row.names=FALSE)