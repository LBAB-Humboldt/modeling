FindBestModel <- function(sp.names, 

#Best model selection (automated method)
setwd("/home/cas/Jorge/Modelos/27112015/bioclim")
sp.names1<-sub("_bc.RData","",list.files(getwd(),"*.RData"))
sp.names2<-sub("_mx.RData","",list.files("/home/cas/Jorge/Modelos/27112015/Maxent","*.RData"))
sp.names3<-sub("_brt.RData","",list.files("/home/cas/Jorge/Modelos/27112015/BRT","*.RData"))

sp.names<-unique(c(sp.names1,sp.names2,sp.names3))

methods=c("bc","brt","mx")
methods2=c("bioclim","BRT","Maxent")
results<-data.frame(Species=sp.names,n.methods=NA, BestMethod=NA,BestThreshold=NA,TSS=NA)

for(i in 1:length(sp.names)){
  rm(m1,m2,m3)
  in.file<-paste0("/home/cas/Jorge/Modelos/27112015/bioclim/",sp.names[i],"_evaluation_bc.csv")
  if(file.exists(in.file)&file.info(in.file)$size>0){
    m1 <- mean(read.csv(in.file,as.is=T)$test.auc)
  }
  
  in.file<-paste0("/home/cas/Jorge/Modelos/27112015/BRT/",sp.names[i],"_evaluation_brt.csv")
  if(file.exists(in.file)&file.info(in.file)$size>0){
    m2 <- mean(read.csv(in.file,as.is=T)$test.auc)
  }
  
  in.file<-paste0("/home/cas/Jorge/Modelos/27112015/Maxent/",sp.names[i],"_evaluation_mx.csv")
  if(file.exists(in.file)&file.info(in.file)$size>0){
    m3 <- mean(read.csv(in.file,as.is=T)$test.auc)
  }
  
  df<-c()
  if(exists("m1")){
    df<-c(df,m1)
  } else {
    df <- c(df,NA)
  }
  
  if(exists("m2")){
    df<-c(df,m2)
  } else {
    df <- c(df,NA)
  }
  
  if(exists("m3")){
    df<-c(df,m3)
  } else {
    df <- c(df,NA)
  }
  results[i,2]<-length(na.omit(df))
  results[i,3]<-methods[which.max(df)]
}

#Now select best threshold
#create random points
raster.obj <- raster("~/Jorge/Capas/bio_1.asc")
cells <- Which(!is.na(raster.obj),cells=T)
sel.cells <- sample(cells, 10000)
sp.abs <- xyFromCell(raster.obj, sel.cells)

raw.thresholds=c(0,10,20,30)
suffixes=paste0(rep(raw.thresholds,2),rep(c("","_cut"),each=4))
source_url("https://raw.githubusercontent.com/LBAB-Humboldt/tools/master/computeTSS.R")

for(i in 1:length(sp.names)){
  print(sp.names[i])
  folder=methods2[match(results[i,3],methods)]
  in.pres <- paste0("/home/cas/Jorge/Modelos/27112015/", folder,
                    "/", sp.names[i],"_",results[i,3], ".csv")
  if(file.exists(in.pres)){
    sp.pres<-read.csv(in.pres, fileEncoding="latin1")
  } else {
    print(paste0("skipping species ",sp.names[i]))
    next
  }
  
  tss<-c()
  for(j in 1:length(suffixes)){
    in.raster<-paste0("/home/cas/Jorge/Modelos/27112015/",folder,
                      "/",sp.names[i],"_",suffixes[j],"_",results[i,3],".tif")
    if(file.exists(in.raster)){
      r1 <- raster(in.raster)
      tss[j] <- computeTSS(r1, sp.pres[,c("lon","lat")], sp.abs)
    } else {
      tss[j] <- NA
    }
  }
  
  if(length(na.omit(tss))==0){
    print(paste0("skipping species ",sp.names[i]))
    next
  }
  results$BestThreshold[i] <- paste0("/home/cas/Jorge/Modelos/27112015/",folder,
                                     "/",sp.names[i],"_",suffixes[which.max(tss)],"_",
                                     results[i,3],".tif")
  results$TSS[i] <- max(tss)
}

write.csv(results,"/home/cas/Jorge/Modelos/27112015/ValidationTab/Inductivo/best_models_updated.csv",row.names=FALSE)
results <- na.omit(results)

#Move files to validation folder
file.copy(results$BestThreshold,"/home/cas/Jorge/Modelos/27112015/ValidationTab/Inductivo")

#Rename files
rm(list=ls())
setwd("/home/cas/Jorge/Modelos/27112015/ValidationTab/Inductivo/")
sp.list <- list.files(getwd(),"*.tif$")
new.names<-sapply(strsplit(sp.list,"_"),"[[",1)
new.names <-paste0(new.names,"_lba.tif")
file.rename(sp.list,new.names)

#Convert2PNG
sp.list <- list.files("/home/cas/Jorge/Modelos/27112015/ValidationTab/Inductivo/","*.tif")
setwd("/home/cas/Jorge/Modelos/27112015/ValidationTab/Inductivo/")
col.pal = rgb(193,140,40,maxColorValue=255)
load("~/Jorge/params.RData")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(sp.list, convert2PNG, in.folder=getwd(), 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()

##Manually fix issues with BRT Models

missing.sp<-c("Guadua angustifolia","Megaceryle torquata","Melinis minutiflora")

a<-read.csv("~/Jorge/Bases/revisedSpecies_24112015.csv",as.is=T)
sp.list<-sort(unique(a$species))
b<-a[a$species%in%missing.sp,]
write.csv(b, "~/Jorge/Bases/missingBRTSpecies_24112015.csv",row.names=F)
rm(list=ls())

source_url("https://raw.githubusercontent.com/LBAB-Humboldt/parallelMaxent/master/brtParallel.R")

brtParallel(occ.file="~/Jorge/Bases/missingBRTSpecies_24112015.csv",
            env.dir="~/Jorge/Capas",
            env.files=paste0("bio_",1:19,".asc"),
            dist=800,
            bkg.aoi="extent",
            bkg.type="random",
            n.bkg=10000,
            sample.bkg = NULL,
            wd="~/Jorge/Modelos/27112015/BRTupdate",
            folds=5,
            do.threshold=TRUE,
            raw.threshold=c(0,10,20,30),
            do.cut=TRUE,
            brt.params=c(5,0.01,0.75),
            n.cpu=3,
            do.eval=T)

rm(list=ls())


#Select best model for missing species
sp.names<-c("Guadua angustifolia","Megaceryle torquata","Nycticorax nycticorax","Paroaria gularis","Picumnus cinnamomeus")

results<-read.csv("/home/cas/Jorge/Modelos/27112015/ValidationTab/Inductivo/best_models.csv",as.is=T)
raster.obj <- raster("~/Jorge/Capas/bio_1.asc")
cells <- Which(!is.na(raster.obj),cells=T)
sel.cells <- sample(cells, 10000)
sp.abs <- xyFromCell(raster.obj, sel.cells)

raw.thresholds=c(0,10,20,30)
suffixes=paste0(rep(raw.thresholds,2),rep(c("","_cut"),each=4))
source_url("https://raw.githubusercontent.com/LBAB-Humboldt/tools/master/computeTSS.R")

for(i in 1:length(sp.names)){
  print(sp.names[i])
  ind<-which(results$Species==sp.names[i])
  folder=methods2[match(results[ind,3],methods)]
  in.pres <- paste0("/home/cas/Jorge/Modelos/27112015/", folder,
                    "/", sp.names[i],"_",results[ind,3], ".csv")
  if(file.exists(in.pres)){
    sp.pres<-read.csv(in.pres, fileEncoding="latin1")
  } else {
    print(paste0("skipping species ",sp.names[i]))
    next
  }
  
  tss<-c()
  for(j in 1:length(suffixes)){
    in.raster<-paste0("/home/cas/Jorge/Modelos/27112015/",folder,
                      "/",sp.names[i],"_",suffixes[j],"_",results[ind,3],".tif")
    if(file.exists(in.raster)){
      r1 <- raster(in.raster)
      tss[j] <- computeTSS(r1, sp.pres[,c("lon","lat")], sp.abs)
    } else {
      tss[j] <- NA
    }
  }
  
  if(length(na.omit(tss))==0){
    print(paste0("skipping species ",sp.names[i]))
    next
  }
  results$BestThreshold[ind] <- paste0("/home/cas/Jorge/Modelos/27112015/",folder,
                                     "/",sp.names[i],"_",suffixes[which.max(tss)],"_",
                                     results[ind,3],".tif")
  results$TSS[ind] <- max(tss)
}

#Create PNGs
setwd("~/Jorge/Modelos/27112015/BRT")
raster.list<-paste0(rep(sp.names,each=4),
                    rep(c("_0_brt.tif","_10_brt.tif","_20_brt.tif","_30_brt.tif"),4))
col.pal = rgb(193,140,40,maxColorValue=255)
load("~/Jorge/params.RData")

source_url("https://raw.githubusercontent.com/LBAB-Humboldt/tools/master/convert2PNG.R")
sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, convert2PNG, in.folder=getwd(), 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()

#Move files to folders
inds<-which(results$Species%in%sp.names)
file.copy(results$BestThreshold[inds],paste0("/home/cas/Jorge/Modelos/27112015/ValidationTab/Inductivo/",
                                       sp.names,"_lba.tif"))
#Create PNGs
setwd("/home/cas/Jorge/Modelos/27112015/ValidationTab/Inductivo/")
raster.list<-paste0(sp.names,"_lba.tif")
col.pal = rgb(193,140,40,maxColorValue=255)
load("~/Jorge/params.RData")

sfInit(parallel=T,cpus=5)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, convert2PNG, in.folder=getwd(), 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()
