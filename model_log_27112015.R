source_url("https://raw.githubusercontent.com/LBAB-Humboldt/parallelMaxent/master/mxParallel.R")

mxParallel(occ.file="~/Jorge/Bases/revisedSpecies_24112015.csv",
           env.dir="~/Jorge/Capas",
           env.files=c(paste0("bio_",1:19,".asc")),
           wd="~/Jorge/Modelos/27112015/Maxent",
           dist=800,
           bkg.aoi = "extent",
           bkg.type="random", 
           n.bkg = 10000, 
           sample.bkg = NULL,
           optimize.lambda=FALSE, 
           folds=5, 
           do.eval=TRUE,
           n.cpu=16,
           mxnt.args=c("autofeature=FALSE","linear=TRUE","quadratic=TRUE","product=FALSE","hinge=TRUE","threshold=FALSE",
                       "extrapolate=FALSE","doclamp=TRUE","addsamplestobackground=TRUE"), 
           do.threshold=TRUE, 
           raw.threshold=c(0,10,20,30), 
           do.cut=TRUE)

source_url("https://raw.githubusercontent.com/LBAB-Humboldt/parallelMaxent/master/bcParallel.R")

bcParallel(occ.file="~/Jorge/Bases/revisedSpecies_24112015.csv",
  env.dir="~/Jorge/Capas",
  env.files=c(paste0("bio_",c(1,2,3,4,12,15,18),".asc")),
  dist=800,
  bkg.aoi = "extent",
  bkg.type="random",
  n.bkg = 10000,
  sample.bkg = NULL,
  folds=5,
  wd="~/Jorge/Modelos/27112015/bioclim",
  do.eval=TRUE,
  n.cpu=16,
  do.threshold=TRUE,
  raw.threshold=c(0,10,20,30),
  do.cut=TRUE)

#BRT 
source_url("https://raw.githubusercontent.com/LBAB-Humboldt/parallelMaxent/master/brtParallel.R")

brtParallel(occ.file="~/Jorge/Bases/revisedSpecies_24112015.csv",
              env.dir="~/Jorge/Capas",
              env.files=paste0("bio_",1:19,".asc"),
              dist=800,
              bkg.aoi="extent",
              bkg.type="random",
              n.bkg=10000,
              sample.bkg = NULL,
              wd="~/Jorge/Modelos/27112015/BRT",
              folds=5,
              do.threshold=TRUE,
              raw.threshold=c(0,10,20,30),
              do.cut=TRUE,
              brt.params=c(5,0.01,0.75),
              n.cpu=16,
              do.eval=T)

#Convert 2 PNG
#Maxent
sp.list <- list.files("~/Jorge/Modelos/27112015/Maxent","*.RData")
setwd("~/Jorge/Modelos/27112015/Maxent")
sp.list<-sub("_mx.RData","",sp.list)
raster.list<-paste0(rep(sp.list,each=4),
                    rep(c("_0_mx.tif","_10_mx.tif","_20_mx.tif","_30_mx.tif"),4))
col.pal = rgb(193,140,40,maxColorValue=255)
load("~/Jorge/params.RData")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, convert2PNG, in.folder=getwd(), 
 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()

#Bioclim
sp.list <- list.files("~/Jorge/Modelos/27112015/bioclim","*.RData")
setwd("~/Jorge/Modelos/27112015/bioclim")
sp.list<-sub(".RData","",sp.list)
raster.list<-paste0(rep(sp.list,each=4),
                    rep(c("_0_bc.tif","_10_bc.tif","_20_bc.tif","_30_bc.tif"),4))
col.pal = rgb(193,140,40,maxColorValue=255)
load("~/Jorge/params.RData")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, convert2PNG, in.folder=getwd(), 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()

#BRT
#rename tifs first
# raster.list <- list.files("~/Jorge/Modelos/27112015/BRT","*.tif$")
# new.raster.list <- sub(".tif","",raster.list)
# new.raster.list <- paste0(new.raster.list, "_brt.tif")
# file.rename(raster.list, new.raster.list)

sp.list <- list.files("~/Jorge/Modelos/27112015/BRT","*.RData")
setwd("~/Jorge/Modelos/27112015/BRT")
sp.list<-sub(".RData","",sp.list)
raster.list<-paste0(rep(sp.list,each=4),
                    rep(c("_0_brt.tif","_10_brt.tif","_20_brt.tif","_30_brt.tif"),4))
col.pal = rgb(193,140,40,maxColorValue=255)
load("~/Jorge/params.RData")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, convert2PNG, in.folder=getwd(), 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()

#IUCN
shp.list <- list.files("~/Jorge/Modelos/27112015/IUCN","*.shp$")
shp.list <- sub(".shp$","",shp.list)
setwd("~/Jorge/Modelos/27112015/IUCN")
raster.tmp<-raster("~/Jorge/Capas/bio_1.asc")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(16:length(shp.list),function(i){
  library(sp)
  library(raster)
  library(rgdal)
  in.shp<-readOGR(getwd(),shp.list[i])
  out.raster<-rasterize(in.shp,raster.tmp,field=rep(1,nrow(in.shp)),background=0)
  writeRaster(out.raster,paste0(shp.list[i],".tif"),overwrite=T)
  convert2PNG(paste0(shp.list[i],".tif"), getwd(), col.pal, TRUE, params=params)
})
sfStop()


#Rename files to standardize names
setwd("~/Jorge/Modelos/27112015/bioclim")
sp.names <- list.files(getwd(),"*.RData")
sp.names <- sub(".RData","",sp.names)
old.names <- c(paste0(sp.names,".RData"), paste0(sp.names,".tif"), 
  paste0(sp.names,".csv"), paste0(sp.names,"_evaluation.csv"))
new.names <- c(paste0(sp.names,"_bc.RData"), paste0(sp.names,"_bc.tif"), 
               paste0(sp.names,"_bc.csv"), paste0(sp.names,"_evaluation_bc.csv"))
file.rename(old.names,new.names)

setwd("~/Jorge/Modelos/27112015/BRT")
sp.names <- list.files(getwd(),"*.RData")
sp.names <- sub(".RData","",sp.names)
old.names <- c(paste0(sp.names,".RData"), paste0(sp.names,".tif"), 
               paste0(sp.names,".csv"), paste0(sp.names,"_evaluation.csv"))
new.names <- c(paste0(sp.names,"_brt.RData"), paste0(sp.names,"_brt.tif"), 
               paste0(sp.names,"_brt.csv"), paste0(sp.names,"_evaluation_brt.csv"))
file.rename(old.names,new.names)

###NOTE: some continuous models missing from BRT
##Repeat BRT Models from species Milvago chimachima

a<-read.csv("~/Jorge/Bases/revisedSpecies_24112015.csv",as.is=T)
sp.list<-sort(unique(a$species))
sp.list<-sp.list[which(sp.list=="Milvago chimachima"):length(sp.list)]
b<-a[(a$species%in%sp.list),]
write.csv(b, "~/Jorge/Bases/revisedSpecies_24112015_v2.csv",row.names=F)
rm(list=ls())

source_url("https://raw.githubusercontent.com/LBAB-Humboldt/parallelMaxent/master/brtParallel.R")

brtParallel(occ.file="~/Jorge/Bases/revisedSpecies_24112015_v2.csv",
            env.dir="~/Jorge/Capas",
            env.files=paste0("bio_",1:19,".asc"),
            dist=800,
            bkg.aoi="extent",
            bkg.type="random",
            n.bkg=10000,
            sample.bkg = NULL,
            wd="~/Jorge/Modelos/27112015/BRT",
            folds=5,
            do.threshold=TRUE,
            raw.threshold=c(0,10,20,30),
            do.cut=TRUE,
            brt.params=c(5,0.01,0.75),
            n.cpu=16,
            do.eval=T)

#BRT
#rename tifs first
sp.list <- list.files("~/Jorge/Modelos/27112015/BRT","*.RData")
setwd("~/Jorge/Modelos/27112015/BRT")
sp.list<-sub("_brt.RData","",sp.list)
raster.list<-paste0(rep(sp.list,each=4),
                    rep(c("_0_brt.tif","_10_brt.tif","_20_brt.tif","_30_brt.tif"),4))
col.pal = rgb(193,140,40,maxColorValue=255)
load("~/Jorge/params.RData")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, convert2PNG, in.folder=getwd(), 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()