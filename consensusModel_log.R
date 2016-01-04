setwd("/home/cas/Jorge/Modelos/27112015/ValidationTab")
library(raster)

df<-read.csv("calificaciones.csv", stringsAsFactors=FALSE,fileEncoding="latin1")

#Remove null 
df<-df[which(!is.na(df$Calificación)),]
  
#Split table by species
sp.list<-sort(unique(df$Especie))

#Create results table
results<-data.frame(Especie=sp.list, n.models=NA, n.experts=NA, consensus=TRUE,obs=NA)

for(i in 1:length(sp.list)){
  print(sp.list[i])
  sub.inv<-df[df$Especie==sp.list[i], c("Especie","Experto","Calificación","Modelo","Umbral.1")]
  sub.inv<-unique(sub.inv)
  
  #Reduce table to max score by expert and only accept scores greater than 2
  maxbyexpert<-tapply(sub.inv[,c("Calificación")],sub.inv[,c("Experto")],max)
  codemax<-paste0(names(maxbyexpert),maxbyexpert)
  codesub<-paste0(sub.inv$Experto,sub.inv$Calificación)
  sub.inv<-sub.inv[which(codesub%in%codemax),]
  sub.inv<-sub.inv[sub.inv$Calificación>=3,]
  
  #
  if(nrow(sub.inv)==0){
    print(paste0("Skipping species ",sp.list[i]))
    results$consensus[i] <- FALSE
    results$obs[i] <- "Ratings less than 3"
    next
  }
  
  #Create stack of rasters
  m <- sub.inv$Modelo
    
  mt<-data.frame(Algoritmo=c("bioclim","BRT","Maxent"),
                 Abr=c("bc","brt","mx"))
    
  m.comp<-as.character(mt[match(m,mt[,2]),1])
    
  file.rasters<-paste0("/home/cas/Jorge/Modelos/27112015/",
                         m.comp, "/",sp.list[i],"_",sub.inv$Umbral.1,"_",m,".tif")
  file.rasters<-file.rasters[file.exists(file.rasters)]
    
  if(length(file.rasters)==0){
    print(paste0("Skipping species ",sp.list[i]))
    results$consensus[i] <- FALSE
    results$obs[i] <- "Raster files not found"
    next
  }
    
  #Compute consensus model
  model.stack<-stack(file.rasters)
  model.avg<-mean(model.stack)
  model.con<-model.avg>=0.5
  writeRaster(model.con,paste0("/home/cas/Jorge/Modelos/27112015/Consenso/",sp.list[i],"_con.tif"),NAflag=-9999,overwrite=T)
  results$n.models[i] <- length(file.rasters)
  results$n.experts[i] <- length(unique(sub.inv$Experto))
}

write.csv(results,"/home/cas/Jorge/Modelos/27112015/Consenso/consenso.csv",row.names=FALSE)
