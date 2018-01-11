#Modeling invasive fauna 
library(mongolite)
library(plyr)
library(devtools)
library(gtools)

setwd("D:/Projects/TallerMM2")
con1 <- mongo(db = "produccion", collection = "records",
              url ="mongodb://biomodelos:#F#W4ff4uV-7Kjmd@192.168.11.105:27018/produccion", verbose = FALSE)
con2 <- mongo(db = "produccion", collection = "species",
              url ="mongodb://biomodelos:#F#W4ff4uV-7Kjmd@192.168.11.105:27018/produccion", verbose = FALSE)

spList<-data.frame(species="Hippopotamus amphibius") #Bring species list

RetrieveSpRecords <- function(spList, con){
  occs <- data.frame()
  log.occs <- data.frame(spList,nOccs=0)
  
  for(i in 1:length(spList)){
    print(spList[i])
    query.result <- con$find(paste0('{"acceptedNameUsage":"', spList[i], '"}'))
    query.result <- cbind(con$find(paste0('{"acceptedNameUsage":"', spList[i], '"}'), fields = '{"_id":1}'), query.result)
    query.result$`__v`<-NULL
    
    if(nrow(query.result)>0){
      rownames(occs)<-NULL
      occs <- rbind(occs, query.result)
      log.occs$nOccs[i] <- nrow(query.result)
    }
  } 
  return(list(occs=occs,log.occs=log.occs))
}

#No se ha corrido script de limpieza sobre ultimas dos especies
#Corrigiendo manualmente
occ.file1 <- RetrieveSpRecords(spList$species, con1)


#Fix extent of bias raster file
#bias.raster<-raster("D:/Datos/bias/predictors/Maxent_output/total_cv/total_avg.asc")
#bias.raster<-resample(bias.raster,env.vars)
#writeRaster(bias.raster,"D:/Datos/bias/predictors/Maxent_output/total_cv/total_avg_newExtent.tif")

#Modeling parameters
wd<-("D:/Projects/Invasoras/Hipopotamo")
env.dir="C:/Capas/aoi/bio/asc"
env.files<-paste0("bio_",c(1,2,3,4,12,15,18),".asc")
occ.file<-occ.file1$occs[, -c(16,17,18)]
bias.raster<-NULL
sp.col <- "acceptedNameUsage"
id.col <- "_id"
dist <- sqrt(2)*1000
n.bkg=10000
mxnt.args=c("autofeature=FALSE","extrapolate=FALSE","doclamp=TRUE","addsamplestobackground=TRUE")
raw.threshold<-c(0,10,20,30)
folds <-5
do.threshold<-TRUE
buffer<-10000
proj.crs<-"+proj=utm +zone=18 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
n.cpu<-1
as.is<-T
prefix<-"HIP"
source_url("https://raw.githubusercontent.com/LBAB-Humboldt/BMModelWF/master/bmWorkflow.R")

bmWorkflow(wd, env.dir, env.files, occ.file, sp.col, id.col, dist, n.bkg,bias.raster,  
           mxnt.args, do.treshold, raw.threshold, folds,buffer,proj.crs,ncpu,as.is,prefix)

#Convert to PNG
source_url("https://raw.githubusercontent.com/LBAB-Humboldt/BMModelWF/master/convert2PNG.R")
load("C:/Users/jorge.velasquez/Documents/GitHub/params.RData")

files<-list.files(wd,"*.tif$",full.names=T)
files.cont<-files[-grep("0_mx|0_bc|_ch",files)]
files.thres<-files[grep("0_mx|0_bc|_ch",files)]

#First create continuous PNGs
colpal<-c(rgb(255, 255, 255, 0, maxColorValue=255),
          rgb(32,131,141,maxColorValue = 255),
          rgb(143,201,143,maxColorValue = 255),
          rgb(237,188,37,maxColorValue = 255),
          rgb(213,120,51,maxColorValue = 255),
          rgb(237,28,36,maxColorValue = 255))

rclmat<-matrix(c(-Inf,0,1,0,0.2,2,0.2,0.4,3,0.4,0.6,4,0.6,0.8,5,0.8,1,6),ncol=3,byrow=T)
names<-sub("D:/Projects/Invasoras/Hipopotamo/","",files.cont)
names<-sub(".tif","",names)

for(i in 1:length(files.cont)){
  print(names[i])
  in.raster<-raster(files.cont[i])
  rc <- reclassify(in.raster, rclmat,include.lowest=F)
  vals<-unique(rc)
  convert2PNG(rc, names[i], getwd(),"D:/Projects/Invasoras/Hipopotamo" ,colpal[vals[vals>0]], FALSE, params,w=179,h=220)
}

#Now create thresholded PNGs
library(snowfall)
col.pal <- rgb(193,140,40,maxColorValue=255)
names<-sub("D:/Projects/Invasoras/Hipopotamo/","",files.thres)
names<-sub(".tif","",names)

sfInit(parallel=T,cpus=1)#Initialize nodes
sfExport(list=c("files.thres","names","params","convert2PNG","col.pal")) #Export vars to all the nodes
sfClusterApplyLB(1:length(files.thres), function(i){
  library(raster)
  in.raster<-raster(files.thres[i])
  convert2PNG(in.raster, names[i],getwd(),"D:/Projects/Invasoras/Hipopotamo",
              col.pal=col.pal,add.trans=TRUE,params=params,w=179,h=220)})
sfStop()

#ZIPs a metadata prepared manually