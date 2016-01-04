#Fix CSV headers
dir.create("U:/Modelos/06082014/CSV")
files <- list.files("U:/Modelos/06082014",pattern="*.RData")
files <- gsub(".RData","",files)


file.copy(paste0("U:/Modelos/06082014/",files, ".csv"),
          paste0("U:/Modelos/06082014/CSV/", files, ".csv"))

file.remove(paste0("U:/Modelos/06082014/",files, ".csv"))

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
            "Evidencia",
            "Publico")


setwd("U:/Modelos/06082014/CSV/")

change.cols<-function(in.file){
  df <- read.csv(paste0(in.file, ".csv"), as.is=T)
  colnames(df) <- col.names
  write.csv(df, paste0(in.file, ".csv"), row.names=FALSE)
}

sapply(files, change.cols)
 