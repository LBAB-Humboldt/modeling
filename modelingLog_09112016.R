occs<-read.csv("initial_occurrences.csv",as.is=T)

#Begin modeling
wd<-"/home/rstudio/test/Modelos/09112016_Herps"
env.dir="/home/rstudio/test/baseData/Capas"
env.files<-paste0("bio_",c(1,2,3,4,12,15,18),".asc")
occ.file<-occs
sp.col <- "species"
id.col <- "id"
dist <- 1
n.bkg=10000
bias.raster<-raster("herps_avg.asc")
mxnt.args=c("autofeature=FALSE","extrapolate=FALSE","doclamp=TRUE","addsamplestobackground=TRUE")
raw.threshold<-c(0,10,20,30)
folds <-5
do.threshold<-TRUE
buffer<-150000
proj.crs<-"+proj=utm +zone=18 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
n.cpu<-15
as.is=TRUE
bmWorkflow(wd, env.dir, env.files, occ.file, sp.col, id.col, dist, n.bkg, bias.raster, 
           mxnt.args, do.treshold, raw.threshold, folds,buffer,proj.crs,ncpu,as.is)

results<-read.csv("./09112016_Herps/results_summary.csv",as.is=T)

#Generate PNGs
bin.list<-results$tifPath[!is.na(results$thresholdType)|results$modelingMethod=="ch"]
bin.list<-sub("/home/rstudio/test/Modelos/09112016_Herps/","",bin.list)
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

#ZIP
dir.create(paste0(wd,"/ZIP"))
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
dir.create(paste0(wd,"/CSV"))
occ.summary<-read.csv(paste0(wd,"/occurrence_summary.csv"),as.is=T)
file.copy(paste0(wd,"/",sub(" ","_",occ.summary$species),".csv"),
          paste0(wd,"/CSV/",sub(" ","_",occ.summary$species),".csv"))
