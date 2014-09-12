load("Base/Registros_2014-07-30.RData")
require("devtools")
require("plyr")
require("raster")

#Compute the number of species that can be modeled verified to department
idx.ebird<-which(set16$DupIndex==0&
                   set16$bien_depto==1&
                   set16$es_aceptadoCoL>0&
                   set16$source=="eBird")   #eBird es verificado hasta departamento pues municipio no esta en su base de datos
idx.snu<-which(set16$DupIndex==0&
                 set16$es_aceptadoCoL>0&
                 set16$source=="Sheffield and Norwegian University") # sin verificar pues son datos de GPS
idx.other<-which(set16$DupIndex==0&
                   set16$bien_muni==1&
                   set16$es_aceptadoCoL>0&
                   set16$source!="eBird"&
                   set16$source!="Sheffield and Norwegian University") # todos los demas verificados hasta municipio.

idx<-unique(c(idx.ebird,idx.snu,idx.other))
occs<-set16[idx,]

#This bit was implemented to determine the number of species that would be modeled
#after applying a municipio filter for most data sources.
# source_url("https://raw.githubusercontent.com/LBAB-Humboldt/parallelMaxent/master/preModelingFunctions.R")
# source_url("https://raw.githubusercontent.com/LBAB-Humboldt/parallelMaxent/master/evaluationFunctions.R")
# source_url("https://raw.githubusercontent.com/LBAB-Humboldt/parallelMaxent/master/postModelingFunctions.R")
# 
# dist=1415
# occs2 <- ddply(occs,.(species),IdNeighbors,dist=dist)
# current.spp <- length(unique(occs2$especie_aceptada))
# current.recs <- nrow(occs2)
# cat(paste(Sys.time(), "After removing  points within",dist, "meters of each other, ",
#           current.recs, "records corresponding to", current.spp, "species remain\n"))
# 
# sp.list <- FilterSpeciesByRecords(occs2, 10)
# if(length(sp.list)==0){
#   return()
# }
# current.spp <- length(sp.list)
# cat(paste(Sys.time(), "After removing species with less than 10 unique records",
#           current.spp, "species remain \n"))

##
out.table<-with(occs, data.frame(id=paste0(source,"_",ID),
species=especie_aceptada,
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
Publico="No",
stringsAsFactors=FALSE))

out.table$Publico[which(occs$source=="eBird")]<-"Si"
out.table$Publico[which(occs$source=="GBIF")]<-"Si"
out.table$Publico[which(occs$source=="SiB")]<-"Si"
out.table$Publico[which(occs$source=="speciesLink")]<-"Si"
out.table$Publico[which(occs$source=="VerNet")]<-"Si"
out.table$Publico[which(occs$source=="Xenocanto")]<-"Si"

write.csv(out.table,"Base/set16_filtered2Muni_06082014.csv",row.names=FALSE)
