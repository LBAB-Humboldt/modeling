#Modeling invasive fauna 
library(mongolite)
library(plyr)
setwd("D:/Projects/Invasoras/Fauna")
con1 <- mongo(db = "produccion", collection = "records",
              url ="mongodb://biomodelos:#F#W4ff4uV-7Kjmd@192.168.11.81:27017/produccion", verbose = FALSE)
con2 <- mongo(db = "produccion", collection = "species",
              url ="mongodb://biomodelos:#F#W4ff4uV-7Kjmd@192.168.11.81:27017/produccion", verbose = FALSE)

spList<-read.csv("D:/Projects/Invasoras/Fauna/speciesList_v2.csv",as.is=T) #Bring species list

RetrieveSpRecords <- function(spList, con){
  occs <- data.frame()
  log.occs <- data.frame(spList,nOccs=0)
  
  for(i in 1:length(spList)){
    query.result <- con$find(paste0('{"acceptedNameUsage":"', spList[i], '"}'))
    query.result <- cbind(con$find(paste0('{"acceptedNameUsage":"', spList[i], '"}'), fields = '{"_id":1}'), query.result)
    if(nrow(query.result)>0){
      rownames(occs)<-NULL
      
      occs <- rbind(occs, query.result)
      log.occs$nOccs[i] <- nrow(query.result)
    }
  } 
  return(list(occs=occs,log.occs=log.occs))
}

occ.file <- RetrieveSpRecords(spList$acceptedNameUsage, con1)

occs.ebird<-occ.file$occs[which(occ.file$occs$source=="eBird"),]
occs.bm<-occ.file$occs[which(occ.file$occs$source=="BioModelos user"),]
occs.other<-occ.file$occs[which(occ.file$occs$source!="eBird"&occ.file$occs$source!="BioModelos user"),]

#Filtro para los registros eBird
occs.ebird$use <- FALSE
occs.ebird$use <- (occs.ebird$hasLocality==1)&
  (occs.ebird$correctStateProvince==1)

#Filtro para los registros de other
occs.other$use <- FALSE
occs.other$use <- (occs.other$correctStateProvince==1)&
                              (occs.other$correctCounty==1)

occs<-rbind(occs.ebird, occs.other, occs.bm)
nUse<-ddply(occs, "acceptedNameUsage", function(df) return(c(nUse=sum(df$use))))
occ.file$log.occs <- merge(occ.file$log.occs,nUse,by.x="spList",by.y="acceptedNameUsage",all.x=T)

write.csv(occs[,1:58],"faunainvasora_initial_occurrences.csv",row.names = FALSE)
write.csv(occ.file$log.occs,"faunainvasora_initial_summary.csv",row.names = FALSE)

#Modeling parameters

wd<-setwd("D:/Projects/Invasoras/Fauna/Modelos")
env.dir="C:/Capas/aoi/bio/asc"
env.files<-paste0("bio_",c(1,2,3,4,12,15,18),".asc")
occ.file<-occs[which(occs$use), 1:58]
#occ.file2<-subset(occ.file,acceptedNameUsage=="Anas platyrhynchos"|
#                    acceptedNameUsage=="Andinoacara latifrons"|
#                    acceptedNameUsage=="Andinoacara pulcher")
sp.col <- "acceptedNameUsage"
id.col <- "occurrenceID"
dist <- sqrt(2)*1000
n.bkg=10000
bias.raster<-raster("C:/Capas/col_mask.asc")
mxnt.args=c("autofeature=FALSE","extrapolate=FALSE","doclamp=TRUE","addsamplestobackground=TRUE")
raw.threshold<-c(0,10,20,30)
folds <-5
do.threshold<-TRUE
buffer<-10000
proj.crs<-"+proj=utm +zone=18 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
n.cpu<-10
as.is<-T
prefix<-"FIN"
source_url("https://raw.githubusercontent.com/LBAB-Humboldt/BMModelWF/master/bmWorkflow.R")

bmWorkflow(wd, env.dir, env.files, occ.file, sp.col, id.col, dist, n.bkg,bias.raster,  
           mxnt.args, do.treshold, raw.threshold, folds,buffer,proj.crs,ncpu,as.is,prefix)
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
