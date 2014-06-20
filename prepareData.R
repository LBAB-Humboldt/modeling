#Select records from set16
load("W:/Ocurrencias/Registros_2014-06-06.RData")

#Verify SIB and GBIF to municipality, everything else accept as is.
idx.gbif<-which(set16$IsDup==0&set16$bien_muni==1&set16$es_aceptadoCoL>0&set16$source=="GBIF")
idx.sib<-which(set16$IsDup==0&set16$bien_muni==1&set16$es_aceptadoCoL>0&set16$source=="SiB")
idx.other<-which(set16$IsDup==0,set16$es_aceptadoCoL>0&set16$source!="SiB"&set16$source!="GBIF")
idx<-c(idx.gbif, idx.sib, idx.other)               
               
set16b<-set16[idx,]
set16b$source[which(set16b$source=="Vernet")]<-"Vertnet"

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
set16.red$Publico[which(set16b$source=="Ecopetrol")]<-"No"
set16.red$Publico[which(set16b$source=="Invasoras")]<-"No"
set16.red$Publico[which(set16b$source=="INVEMAR")]<-"No"
set16.red$Publico[which(set16b$source=="Magnoliaceae")]<-"No"
set16.red$Publico[which(set16b$source=="Política")]<-"No"
set16.red$Publico[which(set16b$source=="SINCHI")]<-"No"

save(set16.red, file="G:/20062014/set16.red.RData")