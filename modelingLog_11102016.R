library(mongolite)

setwd("/home/rstudio/test/Modelos")
con <- mongo(db = "records", collection = "records", 
             url = "mongodb://192.168.11.81:27017")# (esta es la ruta real de donde se pueden tomar los datos).

#con <- mongo(db = "records", collection = "species", url = "mongodb://192.168.11.81:27017")

spList<-read.csv("verifList.csv",as.is=T) #Bring species list

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

occ.file <- RetrieveSpRecords(spList, con)
external.use <- as.numeric((occ.file$occs$dbDuplicate==0)&
                             (occ.file$occs$hasLocality==1)&
                             (occ.file$occs$correctStateProvince==1)&
                             (occ.file$occs$correctCounty==1))        
occ.file$occs$use <- external.use
occ.file$occs$cellID<-as.numeric(occ.file$occs$cellID) #Correcting temporarily an error
nUse<-ddply(occ.file$occs, "acceptedNameUsage", function(df) return(c(nUse=sum(df$use))))
occ.file$log.occs <- merge(occ.file$log.occs,nUse,by.x="species",by.y="acceptedNameUsage",all.x=T)

occ.file$log.occs$nUse<-ddply(occ.file$occs, "acceptedNameUsage", function(df) return(sum(df$use)))$V1
write.csv(occ.file$occs,"initial_occurrences.csv",row.names = FALSE)
write.csv(occ.file$log.occs,"initial_summary.csv",row.names = FALSE)

#Begin modeling

wd<-"/home/rstudio/test/Modelos/11102016"
env.dir="/home/rstudio/test/baseData/Capas"
env.files<-paste0("bio_",c(1,2,3,4,12,15,18),".asc")
occ.file<-occ.file$occs[which(external.use==1), ]
sp.col <- "acceptedNameUsage"
id.col <- "occurrenceID"
dist <- sqrt(2)*1000
n.bkg=10000
bias.raster<-raster("plantae.asc")
mxnt.args=c("autofeature=FALSE","extrapolate=FALSE","doclamp=TRUE","addsamplestobackground=TRUE")
raw.threshold<-c(0,10,20,30)
folds <-5
do.threshold<-TRUE
buffer<-150000
proj.crs<-"+proj=utm +zone=18 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
n.cpu<-15

#Function bmWorkflow run line by line to ensure in was working properly
###

#Prepare files for BioModelos
source("convert2PNG.R")
load("/home/rstudio/test/baseData/params.RData")
col.pal <- rgb(193,140,40,maxColorValue=255)
files <- read.csv("spListParaPNG.csv",as.is=T)[,1]
sfInit(parallel=T,cpus=16)#Initialize nodes
#sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(files, convert2PNG, in.folder=wd, 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()
#Copy csv files to folder
file.copy(paste0(wd,"/",sub(" ","_",occ.summary$acceptedNameUsage),".csv"),
          paste0(wd,"/CSV/",sub(" ","_",occ.summary$acceptedNameUsage),".csv"))
#Zip para descarga
for(i in 1:nrow(results.summary)){
  out.sp.name<-sub(" ","_",results.summary$acceptedNameUsage[i])
  if(is.na(results.summary$thresholdType[i])){
    files<-c(paste0(wd,"/",out.sp.name,"_modelResults.csv"),
             paste0(wd,"/",out.sp.name,"_",results.summary$modelingMethod[i],".tif"))
    zip(paste0(wd,"/ZIP/",out.sp.name,"_",results.summary$modelingMethod[i],".zip"),files)              
  } else {
    files<-c(paste0(wd,"/",out.sp.name,"_ ",results.summary$thresholdType[i],"_modelResults.csv"),
             paste0(wd,"/",out.sp.name,"_",results.summary$thresholdType[i],"_",results.summary$modelingMethod[i],".tif"))
    zip(paste0(wd,"/ZIP/",out.sp.name,"_",results.summary$thresholdType[i],"_",results.summary$modelingMethod[i],".zip"),files)  
  }
}

#Summary files
occs.summary2<-read.csv("initial_summary.csv")
final.summary<-merge(occs.summary2,occ.summary,by.x="species",by.y="acceptedNameUsage",all.x=T)
write.csv(final.summary,"final.summary.csv",row.names=F)

#Forgot to generate PNGs for CH
files<-read.csv("results_summary.csv",as.is=T)
files<-files[files$modelingMethod=="ch","tifPath"]
files<-sub("/home/rstudio/test/Modelos/11102016/","",files)
#source("convert2PNG.R")
#load("/home/rstudio/test/baseData/params.RData")
#col.pal <- rgb(193,140,40,maxColorValue=255)
sfInit(parallel=T,cpus=16)#Initialize nodes
#sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(files, convert2PNG, in.folder=wd, 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()
