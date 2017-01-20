#Modeling primates for APC workshop
con1 <- mongo(db = "records", collection = "records", 
             url = "mongodb://192.168.11.81:27017")# (esta es la ruta real de donde se pueden tomar los datos).
con2 <- mongo(db = "records", collection = "species", 
              url = "mongodb://192.168.11.81:27017")# (esta es la ruta real de donde se pueden tomar los datos).

# df<-con1$find()
# spp<-con2$find()
# taxids<-unique(spp$taxID[which(spp$order=="Primates")])
# ind<-df$taxID%in%taxids
# View(unique(df[ind,c("species","acceptedNameUsage","speciesOriginal")]))

spList<-read.csv("primatesList.csv",as.is=T) #Bring species list
spList[,1]<-trim(spList[,1])
RetrieveSpRecords <- function(spList, con){
  occs <- data.frame()
  log.occs <- data.frame(spList,nOccs=0)
  
  for(i in 1:nrow(spList)){
    query.result <- con$find(paste0('{\"acceptedNameUsage\":\"', spList[i,1], '\"}'))
    if(nrow(query.result)>0){
      occs <- rbind(occs, query.result)
      log.occs$nOccs[i] <- nrow(query.result)
    }
  } 
  return(list(occs=occs,log.occs=log.occs))
}

occ.file <- RetrieveSpRecords(spList, con1)

occs.gbif<-occ.file$occs[which(occ.file$occs$source=="GBIF"),]
occs.apc<-occ.file$occs[which(occ.file$occs$source=="primatesAPC"),]
occs.ara<-occ.file$occs[which(occ.file$occs$source=="primatesARA"),]
occs.splink<-occ.file$occs[which(occ.file$occs$source=="speciesLink"),]

#as.data.frame(table(occs.apc$correctCountry,occs.apc$correctStateProvince,
#                    occs.apc$correctCounty,occs.apc$hasLocality))

#Filtro para los registros GBIF
occs.gbif$use <- as.numeric((occs.gbif$hasLocality==1)&
  (occs.gbif$correctStateProvince==1)&
  (occs.gbif$correctCounty==1))

occs.gbif$use[occs.gbif$acceptedNameUsage=="Aotus vociferans"]<-0
occs.gbif$use[occs.gbif$acceptedNameUsage=="Aotus zonalis"]<-0
occs.gbif$use[occs.gbif$acceptedNameUsage=="Cebus albifrons"]<-0

#Filtro para los registros de speciesLink

occs.splink$use <- as.numeric((occs.splink$hasLocality==1)&
                              (occs.splink$correctCountry==1)&
                              (occs.splink$correctStateProvince==1)&
                              (occs.splink$correctCounty==1))

occs.splink$use[occs.splink$acceptedNameUsage=="Aotus vociferans"]<-0
occs.splink$use[occs.splink$acceptedNameUsage=="Aotus zonalis"]<-0
occs.splink$use[occs.splink$acceptedNameUsage=="Cebus albifrons"]<-0

#Filtro para los registros de ARA
occs.ara$use <- as.numeric((occs.ara$hasLocality==1)&
                                (occs.ara$correctCountry==1)&
                                (occs.ara$correctStateProvince==1)&
                                (occs.ara$correctCounty==1)&
                              (occs.ara$coordUncertaintyM==0))

#Filtro para los registros APC
occs.apc$use <- as.numeric((occs.apc$correctCountry==1)&
                             (occs.apc$correctStateProvince==1)&
                             (occs.apc$correctCounty==1))

occs<-rbind(occs.gbif,occs.splink,occs.ara,occs.apc)
rm(df,occs.apc,occs.ara,occs.splink,occs.gbif)
occs$acceptedNameUsage[occs$acceptedNameUsage=="Ateles geofroyi"]<- "Ateles fusciceps"

occs$cellID<-as.numeric(occs$cellID) #Correcting temporarily an error
nUse<-ddply(occs, "acceptedNameUsage", function(df) return(c(nUse=sum(df$use))))
occ.file$log.occs <- merge(occ.file$log.occs,nUse,by.x="Species",by.y="acceptedNameUsage",all.x=T)

write.csv(occs,"primates_initial_occurrences.csv",row.names = FALSE)
write.csv(occ.file$log.occs,"primates_initial_summary.csv",row.names = FALSE)

#Begin modeling

wd<-"/home/rstudio/test/Modelos/31102016"
env.dir="/home/rstudio/test/baseData/Capas"
env.files<-paste0("bio_",c(1,2,3,4,12,15,18),".asc")
occ.file<-occs[which(occs$use==1), ]
sp.col <- "acceptedNameUsage"
id.col <- "occurrenceID"
dist <- sqrt(2)*1000
n.bkg=10000
bias.raster<-raster("primates_avg.asc")
mxnt.args=c("autofeature=FALSE","extrapolate=FALSE","doclamp=TRUE","addsamplestobackground=TRUE")
raw.threshold<-c(0,10,20,30)
folds <-5
do.threshold<-TRUE
buffer<-150000
proj.crs<-"+proj=utm +zone=18 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
n.cpu<-15

bmWorkflow(wd, env.dir, env.files, occ.file, sp.col, id.col, dist, n.bkg, bias.raster, 
           mxnt.args, do.treshold, raw.threshold, folds,buffer,proj.crs,ncpu)
results<-read.csv("./31102016/results_summary.csv",as.is=T)

#Generate PNGs
bin.list<-results$tifPath[!is.na(results$thresholdType)|results$modelingMethod=="ch"]
bin.list<-sub("/home/rstudio/test/Modelos/31102016/","",bin.list)
names<-sub(".tif","",bin.list)
#145 205 v1
#179, 220 v2
source("convert2PNG.R")
load("/home/rstudio/test/baseData/params.RData")
col.pal <- rgb(193,140,40,maxColorValue=255)

#Version 1
sfInit(parallel=T,cpus=15)#Initialize nodes
sfExport(list=c("bin.list","names","wd","params","convert2PNG","col.pal")) #Export vars to all the nodes
sfClusterApplyLB(1:length(bin.list), function(i){
  convert2PNG(bin.list[i], names[i],in.folder=wd,col.pal=col.pal,add.trans=TRUE, 
              params=params,w=145,h=205)})
sfStop()
#change dir name from PNG to PNG_v1 and from thumb to thumb_v1
#Version 2
sfInit(parallel=T,cpus=15)#Initialize nodes
sfExport(list=c("bin.list","names","wd","params","convert2PNG","col.pal")) #Export vars to all the nodes
sfClusterApplyLB(1:length(bin.list), function(i){
  convert2PNG(bin.list[i], names[i],in.folder=wd,col.pal=col.pal,add.trans=TRUE, 
              params=params,w=179,h=220)})
sfStop()

#Continuous models (only version 2)
con.list<-results$tifPath[is.na(results$thresholdType)&(results$modelingMethod!="ch")]
con.list<-sub("/home/rstudio/test/Modelos/31102016/","",con.list)
names<-sub(".tif","",con.list)

colpal<-c(rgb(255, 255, 255, 0, maxColorValue=255),
          rgb(32,131,141,maxColorValue = 255),
          rgb(143,201,143,maxColorValue = 255),
          rgb(237,188,37,maxColorValue = 255),
          rgb(213,120,51,maxColorValue = 255),
          rgb(237,28,36,maxColorValue = 255))

rclmat<-matrix(c(-Inf,0,1,0,0.2,2,0.2,0.4,3,0.4,0.6,4,0.6,0.8,5,0.8,1,6),ncol=3,byrow=T)

for(i in 1:length(con.list)){
  print(con.list[i])
  in.raster<-raster(paste0(wd,"/",con.list[i]))
  rc <- reclassify(in.raster, rclmat,include.lowest=F)
  vals<-unique(rc)
  convert2PNG(rc, names[i], wd, colpal[vals[vals>0]], FALSE, params,w=179,h=220)
}

#ZIP
for(i in 1:nrow(results)){
  out.name <- sub(" ","_",results$acceptedNameUsage[i])
  if(is.na(results$thresholdType[i])){
    files<-c(paste0(wd,"/",out.name,"_modelResults.csv"),
             results$tifPath[i])
    zip(paste0(wd,"/ZIP/",out.name,"_",results$modelingMethod[i],".zip"),files,flags="-j")              
  } else {
    files<-c(paste0(wd,"/",out.name,"_", results$thresholdType[i],"_modelResults.csv"),
             results$tifPath[i])
    zip(paste0(wd,"/ZIP/",out.name,"_",results$thresholdType[i],"_",results$modelingMethod[i],".zip"),files,flags="-j")              
  }
}

#CSV
occ.summary<-read.csv(paste0(wd,"/occurrence_summary.csv"),as.is=T)
file.copy(paste0(wd,"/",sub(" ","_",occ.summary$acceptedNameUsage),".csv"),
          paste0(wd,"/CSV/",sub(" ","_",occ.summary$acceptedNameUsage),".csv"))
