occs<-read.csv("Zamias_BM_15Nov.csv",as.is=T,encoding ="utf-8")


#Begin modeling
wd<-"/home/rstudio/test/Modelos/21112016_Zamias"
dir.create(wd)
env.dir="/home/rstudio/test/baseData/Capas"
env.files<-paste0("bio_",c(1,2,3,4,12,15,18),".asc")
occ.file<-occs
sp.col <- "species"
id.col <- "id"
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
as.is=TRUE
bmWorkflow(wd, env.dir, env.files, occ.file, sp.col, id.col, dist, n.bkg, bias.raster, 
           mxnt.args, do.treshold, raw.threshold, folds,buffer,proj.crs,ncpu,as.is)

#Run again without bioclim, and maxent after 4 records
wd<-"/home/rstudio/test/Modelos/21112016_Zamias2"
dir.create(wd)
env.dir="/home/rstudio/test/baseData/Capas"
env.files<-paste0("bio_",c(1,2,3,4,12,15,18),".asc")
occ.file<-occs
sp.col <- "species"
id.col <- "id"
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
as.is=TRUE
bmWorkflow(wd, env.dir, env.files, occ.file, sp.col, id.col, dist, n.bkg, bias.raster, 
           mxnt.args, do.treshold, raw.threshold, folds,buffer,proj.crs,ncpu,as.is)