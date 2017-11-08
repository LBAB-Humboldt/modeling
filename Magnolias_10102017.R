#Modeling invasive fauna 
library(mongolite)
library(plyr)
library(devtools)
library(gtools)

setwd("D:/Projects/Magnolias2017")
con1 <- mongo(db = "produccion", collection = "records",
              url ="mongodb://biomodelos:#F#W4ff4uV-7Kjmd@192.168.11.105:27017/produccion", verbose = FALSE)
con2 <- mongo(db = "produccion", collection = "species",
              url ="mongodb://biomodelos:#F#W4ff4uV-7Kjmd@192.168.11.105:27017/produccion", verbose = FALSE)

spList<-read.csv("D:/Projects/Magnolias2017/spList.csv",as.is=T) #Bring species list

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

#Organizar archivos de inicializacion
occ.file <- RetrieveSpRecords(unique(spList$species[1:32]), con1)
nUse<-ddply(occ.file$occs, "acceptedNameUsage", function(df) return(c(nUse=sum(df$use))))
occ.file$log.occs <- merge(occ.file$log.occs,nUse,by.x="spList",by.y="acceptedNameUsage",all.x=T)
write.csv(occ.file$occs[,1:57],"magnolias_initial_occurrences.csv",row.names = FALSE)
write.csv(occ.file$log.occs,"magnolias_initial_summary.csv",row.names = FALSE)

#Fix extent of bias raster file
bias.raster<-raster("D:/Datos/bias/predictors/Maxent_output/plantae_cv/plantae_avg.asc")
tmp<-raster("C:/Capas/aoi/bio/asc/bio_1.asc")
bias.raster<-resample(bias.raster,tmp)
writeRaster(bias.raster,"D:/Datos/bias/predictors/Maxent_output/plantae_cv/plantae_avg_newExtent.tif")
rm(tmp,bias.raster)

#Modeling parameters
wd<-("D:/Projects/Magnolias2017/Modelos")
env.dir="C:/Capas/aoi/bio/asc"
env.files<-paste0("bio_",c(1,2,3,4,12,15,18),".asc")
occ.file<-occ.file$occs[which(occ.file$occs$use), 1:57]

sp.col <- "acceptedNameUsage"
id.col <- "_id"
dist <- sqrt(2)*1000
n.bkg=10000
bias.raster<-raster("D:/Datos/bias/predictors/Maxent_output/plantae_cv/plantae_avg_newExtent.tif")
mxnt.args=c("autofeature=FALSE","extrapolate=FALSE","doclamp=TRUE","addsamplestobackground=TRUE")
raw.threshold<-c(0,10,20,30)
folds <-5
do.threshold<-TRUE
buffer<-10000
proj.crs<-"+proj=utm +zone=18 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
n.cpu<-10
as.is<-T
prefix<-"MGN"
source_url("https://raw.githubusercontent.com/LBAB-Humboldt/BMModelWF/master/bmWorkflow.R")

bmWorkflow(wd, env.dir, env.files, occ.file, sp.col, id.col, dist, n.bkg,bias.raster,  
           mxnt.args, do.treshold, raw.threshold, folds,buffer,proj.crs,ncpu,as.is,prefix)

#Convert to PNG
source_url("https://raw.githubusercontent.com/LBAB-Humboldt/BMModelWF/master/convert2PNG.R")
load("C:/Users/jorge.velasquez/Documents/GitHub/params.RData")

files<-list.files("D:/Projects/Magnolias2017/Modelos","*.tif$",full.names=T)
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
names<-sub("D:/Projects/Magnolias2017/Modelos/","",files.cont)
names<-sub(".tif","",names)

for(i in 1:length(files.cont)){
  print(names[i])
  in.raster<-raster(files.cont[i])
  rc <- reclassify(in.raster, rclmat,include.lowest=F)
  vals<-unique(rc)
  convert2PNG(rc, names[i], getwd(),"D:/Projects/Magnolias2017/Modelos" ,colpal[vals[vals>0]], FALSE, params,w=179,h=220)
}

#Now create thresholded PNGs
library(snowfall)
col.pal <- rgb(193,140,40,maxColorValue=255)
names<-sub("D:/Projects/Magnolias2017/Modelos","",files.thres)
names<-sub(".tif","",names)

sfInit(parallel=T,cpus=10)#Initialize nodes
sfExport(list=c("files.thres","names","params","convert2PNG","col.pal")) #Export vars to all the nodes
sfClusterApplyLB(1:length(files.thres), function(i){
  library(raster)
  in.raster<-raster(files.thres[i])
  convert2PNG(in.raster, names[i],getwd(),"D:/Projects/Magnolias2017/Modelos",
              col.pal=col.pal,add.trans=TRUE,params=params,w=179,h=220)})
sfStop()

#Finally create zip files
#Edited file in excel on fields png, thumb, zip, license, userid,
#model authors, isactive, customcitation
#!!!FOUND AN ERROR WITH THE RECORDING OF THRESHOLDVALUE IN BMWORKFLOW.
#!!!THERES ANOTHER ERROR WITH THE THUMB AND PNG NAMES. THE CURRENT SCRIPT
#!!!ERASES ANY .TIF WITHIN SPECIES NAME
#FIXED MANUALLY FILE NAMES 

#Rename some files because of existing models
files2ren<-read.csv("D:/Projects/TallerMM2/renameFiles.csv",as.is=T,header=F)
setwd("D:/Projects/TallerMM2/Modelos/PNG")
file.rename(files2ren$V1,files2ren$V2)
setwd("D:/Projects/TallerMM2/Modelos/thumb")
file.rename(files2ren$V1,files2ren$V2)
setwd("D:/Projects/TallerMM2/Modelos")
file.rename(files2ren$V1,files2ren$V2)

results<-read.csv("D:/Projects/Magnolias2017/metadata_allMagnolias.csv",as.is=T)

#ZIP
setwd("D:/Projects/Magnolias2017/Modelos")
results<-results[results$thresholdType=="Continuous",]
out.names <- results$zip
out.csvs <- sub(".zip", ".csv", out.names)
for(i in 1:nrow(results)){
  if(results$thresholdType[i]=="Continuous"){
    write.csv(results[i,], paste0("./zip/",out.csvs[i]),row.names=F)
    files<-c(paste0(getwd(),"/zip/",out.csvs[i]),
             paste0(getwd(),"/",sub(".zip",".tif",results$zip[i])))
    zip(paste0(getwd(),"/zip/",out.names[i]),files,flags="-j")
    file.remove(paste0(getwd(),"/zip/",out.csvs[i]))
  } 
}


#Prepare file with update to use column
init.occs<-read.csv("D:/Projects/Magnolias2017/magnolias_initial_occurrences.csv",as.is=T)
final.occs<-read.csv("D:/Projects/Magnolias2017/Modelos/occurrences.csv",as.is=T)
init.occs$use<-(init.occs$X_id%in%final.occs$X_id)
write.csv(init.occs[,c(1,4,26,57,56)],"D:/Projects/Magnolias2017/updateUseColumn.csv")
