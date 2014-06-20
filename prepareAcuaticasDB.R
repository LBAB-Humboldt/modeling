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

#Now import libro rojo list and validate taxonomy
libro.rojo<-read.xlsx("G:/Acuaticas/TallerBogota/Registros Acuáticas Libro Rojo_import.xlsx",1,stringsAsFactors=F)
cofTable <- spTable(libro.rojo$speciesOriginal, " ")
lr.valid <- nameValidation(con, cofTable)
libro.rojo2<-cbind(libro.rojo,lr.valid)

####

#Select records from set16
load("W:/Ocurrencias/Registros_2014-06-06.RData")
sp.acc<-paste0(set16$genero_aceptado," ",set16$epiteto_aceptado)
sp.list<-paste0(sp.list.valid$genero_aceptado," ",sp.list.valid$epiteto_aceptado)

#set16<-cbind(set16[1:13],alt=set16$alt[1],set16[15:59])

idx.acc <-which(sp.acc %in% sp.list)
set16<-set16[idx.acc, ]


#Remove collection duplicates and that have been verified to municipality
idx.gbif<-which(set16$IsDup==0&set16$bien_muni==1&set16$es_aceptadoCoL>0&set16$source=="GBIF")
idx.sib<-which(set16$IsDup==0&set16$bien_muni==1&set16$es_aceptadoCoL>0&set16$source=="SiB")
idx.other<-which(set16$IsDup==0,set16$es_aceptadoCoL>0&set16$source!="SiB"&set16$source!="GBIF")

idxB<-c(idx.gbif,idx.sib,idx.other)
set16b<-set16[idxB,]

#Merge Libro Rojo and set16
set16.red<-with(set16b, data.frame(id=paste0(source,"_",ID),
                        species=paste0(genero_aceptado,"_",epiteto_aceptado),
                        EspecieOriginal=speciesOriginal,
                        lon=lon,
                        lat=lat,
                        Localidad=locality,
                        Municipio=adm2,
                        Departamento=adm1,
                        Pais=country,
                        Altitud=alt,
                        Fecha=earliestDateCollected,
                        Institucion=institution,
                        Colector=collector,
                        Evidencia=basisOfRecord,
                        Publico="Si",
                        stringsAsFactors=FALSE))

set16.red$Publico[which(set16b$source=="DATAcuaticas")]<-"No"
set16.red$Publico[which(set16b$source=="Invasoras")]<-"No"


lr.red<-with(libro.rojo2, data.frame(id=paste0(source,"_",occurrenceID),
                                   species=paste0(genero_aceptado,"_",epiteto_aceptado),
                                   EspecieOriginal=speciesOriginal,
                                   lon=lon,
                                   lat=lat,
                                   Localidad=locality,
                                   Municipio=adm2,
                                   Departamento=adm1,
                                   Pais=country,
                                   Altitud=alt,
                                   Fecha=earliestDateCollected,
                                   Institucion=institution,
                                   Colector=collector,
                                   Evidencia=basisOfRecord,
                                   Publico="No"))

aquatic.db<-rbind(set16.red,lr.red)
write.csv(aquatic.db,"G:/Acuaticas/TallerBogota/aquatic.db3.csv",row.names=FALSE)
#Manually deleted odd entries in latitude and logitude fields


