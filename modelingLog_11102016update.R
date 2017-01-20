#Adding new models to run that were not previously included
load("invasiveSpp_13217Records.RData")
occ.file<-set16Inv
occ.file<-occ.file[which(!is.na(occ.file$acceptedNameUsage)),]
external.use <- as.numeric((occ.file$dbDuplicate==0)&
                             (occ.file$hasLocality==1)&
                             (occ.file$correctStateProvince==1)&
                             (occ.file$correctCounty==1))

occ.file$use <- external.use
sp.occs<-occ.file[which(occ.file$acceptedNameUsage=="Acacia decurrens"),]
nOccs<-ddply(occ.file, "acceptedNameUsage", function(df) return(c(nOccs=nrow(df))))
nUse<-ddply(occ.file, "acceptedNameUsage", function(df) return(c(nUse=sum(df$use,na.rm=T))))
log.occs <- data.frame(nOccs,nUse=nUse$nUse)

write.csv(occ.file,"initial_occurrences.csv",row.names = FALSE)
write.csv(log.occs,"initial_summary.csv",row.names = FALSE)

#Begin modeling

wd<-"/home/rstudio/test/Modelos/11102016update"
env.dir="/home/rstudio/test/baseData/Capas"
env.files<-paste0("bio_",c(1,2,3,4,12,15,18),".asc")
occ.file<-occ.file[which(external.use==1), ]
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

###!!!NEED TO PUT MODEL TEMPLATE AS AN ARGUMENTT!!!
###Avoid saving full path in zip files
###Document code
source("modelingWorkflow.R")
bmWorkflow(wd, env.dir, env.files, occ.file, sp.col, id.col, dist, n.bkg, bias.raster, 
                     mxnt.args, do.treshold, raw.threshold, folds,buffer,proj.crs,ncpu)

#Generate PNGs etc
source("convert2PNG.R")
load("/home/rstudio/test/baseData/params.RData")
col.pal <- rgb(193,140,40,maxColorValue=255)

##!!!Sigue habiendo un error en la escritura de las rutas de tifs despues del raw_threshold falta _
files<-list.files(wd,"*.tif$")
sfInit(parallel=T,cpus=15)#Initialize nodes
#sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(files, convert2PNG, in.folder=wd, 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()

#Copy csv files to folder
occ.summary<-read.csv(paste0(wd,"/occurrence_summary.csv"),as.is=T)
file.copy(paste0(wd,"/",sub(" ","_",occ.summary$acceptedNameUsage),".csv"),
          paste0(wd,"/CSV/",sub(" ","_",occ.summary$acceptedNameUsage),".csv"))

#Zip para descarga
results.summary<-read.csv(paste0(wd,"/results_summary.csv"),as.is=T)

for(i in 1:nrow(results.summary)){
  out.sp.name<-sub(" ","_",results.summary$acceptedNameUsage[i])
  if(is.na(results.summary$thresholdType[i])){
    files<-c(paste0(wd,"/",out.sp.name,"_modelResults.csv"),
             paste0(wd,"/",out.sp.name,"_",results.summary$modelingMethod[i],".tif"))
    zip(paste0(wd,"/ZIP/",out.sp.name,"_",results.summary$modelingMethod[i],".zip"),files)              
  } else {
    files<-c(paste0(wd,"/",out.sp.name,"_",results.summary$thresholdType[i],"_modelResults.csv"),
             paste0(wd,"/",out.sp.name,"_",results.summary$thresholdType[i],"_",results.summary$modelingMethod[i],".tif"))
    zip(paste0(wd,"/ZIP/",out.sp.name,"_",results.summary$thresholdType[i],"_",results.summary$modelingMethod[i],".zip"),files)  
  }
}

#Summary files
occs.summary2<-read.csv("initial_summary.csv")
final.summary<-merge(occs.summary2,occ.summary,by.x="acceptedNameUsage",by.y="acceptedNameUsage",all.x=T)
write.csv(final.summary,"final.summary.csv",row.names=F)

###Create continuous PNGs
source("convert2PNG.R")
colpal<-c(rgb(255, 255, 255, 0, maxColorValue=255),
          rgb(32,131,141,maxColorValue = 255),
          rgb(143,201,143,maxColorValue = 255),
          rgb(237,188,37,maxColorValue = 255),
          rgb(213,120,51,maxColorValue = 255),
          rgb(237,28,36,maxColorValue = 255))
rclmat<-matrix(c(-Inf,0,1,0,0.2,2,0.2,0.4,3,0.4,0.6,4,0.6,0.8,5,0.8,1,6),ncol=3,byrow=T)

load("/home/rstudio/test/baseData/params.RData")

sp.list<-read.csv("/home/rstudio/test/Modelos/11102016/SummaryFiles/final.summary.csv",as.is=T)
sp.list<-sp.list[which(sp.list$modelType!="ch"&!(is.na(sp.list$TIFs))),c("species","modelType")]

for(i in 1:nrow(sp.list)){
  file.name<-paste0(sub(" ","_",sp.list[i,"species"]),"_",sp.list[i,"modelType"])
  print(file.name)
  in.raster<-raster(paste0("/home/rstudio/test/Modelos/11102016/",file.name,".tif"))
  rc<-reclassify(in.raster, rclmat, include.lowest=F)
  vals<-unique(rc)
  convert2PNG(rc, file.name, "/home/rstudio/test/Modelos/11102016PNGupdate2", colpal[vals[vals>0]], FALSE , params)
}

#for update folder
sp.list<-read.csv("/home/rstudio/test/Modelos/final.summary.csv",as.is=T)
sp.list<-sp.list[which(sp.list$modelType!="ch"&!(is.na(sp.list$TIFs))),c("acceptedNameUsage","modelType")]

for(i in 1:nrow(sp.list)){
  file.name<-paste0(sub(" ","_",sp.list[i,"acceptedNameUsage"]),"_",sp.list[i,"modelType"])
  print(file.name)
  in.raster<-raster(paste0("/home/rstudio/test/Modelos/11102016update/",file.name,".tif"))
  rc<-reclassify(in.raster, rclmat, include.lowest=F)
  vals<-unique(rc)
  convert2PNG(rc, file.name, "/home/rstudio/test/Modelos/11102016PNGupdate2", colpal[vals[vals>0]], FALSE , params)
}

#moved all PNG to /home/gic/test/Modelos/11102016PNGupdate
#Need to generate new PNG with new extent for thumbnails
#Part 1
##These thumbnails are not actually needed since thumbnails with this extent are not shown in BioModelos v2
##They are not updated with the latest thumbnail size for biomodelos 2
source("convert2PNG.R")
col.pal <- rgb(193,140,40,maxColorValue=255)
files <- read.csv("./11102016/SummaryFiles/spListParaPNG.csv",as.is=T)[,1]
load("/home/rstudio/test/baseData/params.RData")

for(i in 1:length(files)){
  file.name<-strsplit(files[i],"\\.")[[1]][1]
  print(file.name)
  in.raster<-raster(paste0("/home/rstudio/test/Modelos/11102016/",file.name,".tif"))
  convert2PNG(in.raster, file.name, "/home/rstudio/test/Modelos/11102016PNGupdate", col.pal, TRUE, params)
}

#Part 2
##These thumbnails are not actually needed since thumbnails with this extent are not shown in BioModelos v2
##They are not updated with the latest thumbnail size for biomodelos 2

source("convert2PNG.R")
load("/home/rstudio/test/baseData/params.RData")
col.pal <- rgb(193,140,40,maxColorValue=255)

##!!!Sigue habiendo un error en la escritura de las rutas de tifs despues del raw_threshold falta _
files<-list.files("/home/rstudio/test/Modelos/11102016update","*0_mx.tif$")
files2<-list.files("/home/rstudio/test/Modelos/11102016update","*0_bc.tif$")
files<-c(files,files2)
rm(files2)
for(i in 1:length(files)){
  file.name<-strsplit(files[i],"\\.")[[1]][1]
  print(file.name)
  in.raster<-raster(paste0("/home/rstudio/test/Modelos/11102016update/",file.name,".tif"))
  convert2PNG(in.raster, file.name, "/home/rstudio/test/Modelos/11102016PNGupdate", col.pal, TRUE, params)
}