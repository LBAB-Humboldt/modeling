library(raster)
library(rgdal)
template<-raster("~/Jorge/Capas/bio_1.asc")
template[Which(!is.na(template))]<-0

#Segunda aproximacion (usada)
template1<-template
template1[Which(template1==0)]<-1

shp.dir<-"~/Jorge/Modelos/27112015/expertShapes"
setwd(shp.dir)
shp.list<-list.files(shp.dir,"*.shp")
sp.list <- sub(".shp","",sapply(strsplit(shp.list,"_"),"[[",2))
sp.list2<- sort(unique(sp.list))

results<-data.frame(Especie=sp.list2,Valid=1)
for(i in 1:length(sp.list2)){
  print(sp.list2[i])
  sub.files<-shp.list[sp.list==sp.list2[i]]
  over.template<-template
  eoo.template<-template
  for(j in 1:length(sub.files)){
    in.shp<-readOGR(".", sub(".shp", "", sub.files[j]))
    if(in.shp@data$Accion=="Cut"){
      r1<-rasterize(in.shp,template,background=0)
      over.template<-over.template+r1
    }
    if(in.shp@data$Accion=="Add"){
      r1<-rasterize(in.shp,template,background=0)
      eoo.template<-eoo.template+r1
    }
  }
  m1<-template1
  m1[Which(over.template>0)]<-0 #Remueve todo lo que sea clasificado como sobreprediccion
  t.eoo<-cellStats(eoo.template,"max")/2
  m1[Which(eoo.template>=t.eoo)]<-1 #Agrega a  la mascara areas en las que mas de la mitad de los expertos considera que esta la especie
  
  in.raster<-paste0("~/Jorge/Modelos/27112015/Consenso/",sp.list2[i],"_con.tif")
  if(file.exists(in.raster)){
    r2<-raster(in.raster)
  } else {
    results$Valid[i]=0
    next
  }
  r.valid<-m1*r2
  writeRaster(r.valid, paste0("~/Jorge/Modelos/27112015/ValidationTab/BM/",sp.list2[i],"_bm.tif"))
}
write.csv(results,"~/Jorge/Modelos/27112015/ValidationTab/validShape.csv",row.names=FALSE)

#Copy and rename files from consensus for those without editions
rm(list=ls())
setwd("~/Jorge/Modelos/27112015/Consenso/")
sp.files<-list.files("~/Jorge/Modelos/27112015/Consenso/","*.tif$")
sp.names<-sub("_con.tif","",sp.files)
results<-data.frame(Especie=sp.names,Edits=1)
for(i in 1:length(sp.names)){
  file.name<-paste0("~/Jorge/Modelos/27112015/ValidationTab/BM/",sp.names[i],"_bm.tif")
  if(file.exists(file.name)){
    next
  } else {
    file.copy(sp.files[i], file.name)
    results$Edits <- 0
  }
}
#Olvide guardar el results antes de remover todos los objetos

#Convert2PNG
rm(list=ls())
raster.list <- list.files("~/Jorge/Modelos/27112015/ValidationTab/BM","*.tif$")
setwd("~/Jorge/Modelos/27112015/ValidationTab/BM")
col.pal = rgb(193,140,40,maxColorValue=255)
load("~/Jorge/params.RData")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, convert2PNG, in.folder=getwd(), 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()

