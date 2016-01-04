#Remover columna publico y registros que no lo sean
col.names<-c("ID",
             "species",
             "Nombre original",
             "lon",
             "lat",
             "Localidad",
             "Municipio",
             "Departamento",
             "País",
             "Altitud",
             "Fecha",
             "Institución",
             "Colector",
             "Evidencia")


setwd("U:/Modelos/06082014/CSV")
files<-list.files(getwd(),pattern="*.csv")
for(i in 1:length(files)){
  in.file <- read.csv(files[i],as.is=T)
  ind.row <- which(in.file$Publico=="Si")
  in.file <- in.file[ind.row, 1:14]
  colnames(in.file) <- col.names
  write.csv(in.file, paste0("U:/Modelos/06082014/CSV2/", files[i]),
            row.names=FALSE)
}

#Cambiando los csv de acuaticas
col.names<-c("ID",
             "species",
             "Nombre original",
             "lon",
             "lat",
             "Localidad",
             "Municipio",
             "Departamento",
             "País",
             "Altitud",
             "Fecha",
             "Institución",
             "Colector",
             "Evidencia")

setwd("U:/Modelos/TallerBogota/CSV")
files<-list.files(getwd(),pattern="*.csv")
for(i in 1:length(files)){
  in.file <- read.csv(files[i],as.is=T)
  ind.row <- which(in.file$Publico=="Si")
  in.file <- in.file[ind.row, 1:14]
  colnames(in.file)<-col.names
  write.csv(in.file, paste0("U:/Modelos/TallerBogota/CSV2/", files[i]),
            row.names=FALSE)
}

#Ahora los de invasoras

setwd("U:/Modelos/invasoras/CSV")
files<-list.files(getwd(),pattern="*.csv")
for(i in 1:length(files)){
  in.file <- read.csv(files[i],as.is=T)
  ind.row <- which(in.file$Publico=="Si")
  in.file <- in.file[ind.row,1:14]
  colnames(in.file)<-col.names
  write.csv(in.file, paste0("U:/Modelos/invasoras/CSV2/", files[i]))
}