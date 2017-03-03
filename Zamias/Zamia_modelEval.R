#Fix issues
#Create missing files in Consenso
tmplte<-raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/21112016_Zamias2/Zamia_amazonum_0_mx.tif")
zamazonum<-raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso_NA/Zamia_amazonum_con3.tif")
zamazonum[Which(is.na(zamazonum))]<-0
zamazonum[Which(is.na(tmplte))]<-NA
writeRaster(zamazonum, "//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso/Zamia_amazonum_con3.tif")

tmplte<-raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/21112016_Zamias2/Zamia_amazonum_0_mx.tif")
zhymeno<-raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso_NA/Zamia_hymenophyllidia_con3.tif")
zhymeno[Which(is.na(zhymeno))]<-0
zhymeno[Which(is.na(tmplte))]<-NA
writeRaster(zhymeno, "//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso/Zamia_hymenophyllidia_con3.tif")

tmplte<-raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/21112016_Zamias2/Zamia_amazonum_0_mx.tif")
zamazonum<-raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso_NA/Zamia_amazonum_con4.tif")
zamazonum[Which(is.na(zamazonum))]<-0
zamazonum[Which(is.na(tmplte))]<-NA
writeRaster(zamazonum, "//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso/Zamia_amazonum_con4.tif")

#For Zamia amplifolia, include points used in minimum convex polygon creation in prediction
zamplifolia<-raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso_NA/Zamia_amplifolia_con.tif")
spOccs<-read.csv(paste0("Z:/Modelos/Zamias/21112016_Zamias2/Zamia_amplifolia.csv"),as.is=T)
cells<-extract(zamplifolia,spOccs[,c("lon","lat")],cellnumbers=T)
zamplifolia[cells[,1]]<-1
writeRaster(zamplifolia,"//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso_NA/Zamia_amplifolia_con.tif",overwrite=T)

zamplifolia<-raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso/Zamia_amplifolia_con.tif")
spOccs<-read.csv(paste0("Z:/Modelos/Zamias/21112016_Zamias2/Zamia_amplifolia.csv"),as.is=T)
cells<-extract(zamplifolia,spOccs[,c("lon","lat")],cellnumbers=T)
zamplifolia[cells[,1]]<-1
writeRaster(zamplifolia,"//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso/Zamia_amplifolia_con.tif",overwrite=T)

#Update level 2 Zamia amplifolia
z.amplif<-raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso/Zamia_amplifolia_con.tif")
z.amplif_veg<-raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/vegMasks/Zamia amplifolia.tif")
z.amplif_veg<-extend(z.amplif_veg,z.amplif)
extent(z.amplif_veg)<-extent(z.amplif)
z.amplif_n2<-z.amplif_veg*z.amplif
writeRaster(z.amplif_n2,"//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Nivel2/Zamia_amplifolia_veg.tif",overwrite=T)

z.amplif_n2[Which(z.amplif_n2<0.5)]<-NA
z.amplif_n2[Which(z.amplif_n2>=0.5)]<-1
writeRaster(z.amplif_n2,"//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Nivel2_NA/Zamia_amplifolia_veg.tif",overwrite=T)

###Need to use another threshold for Zamias after clipping for vegetation
rasterList<-list.files("Z:/Modelos/Zamias/Nivel2","*.tif$",full.names=T)
rasterNames<-list.files("Z:/Modelos/Zamias/Nivel2_NA","*.tif$")

#Check if they all have the same extent and resolution
stack(rasterList) #No error after running means they all have the same extent and resolution

for(i in 1:length(rasterList)){
  inRaster<-raster(rasterList[i])
  outRaster<-inRaster>0
  outRaster[Which(outRaster==0)] <- NA
  writeRaster(outRaster,paste0("Z:/Modelos/Zamias/Nivel2_NA2/", 
                               rasterNames[i]))
}

##compute stats
tifs<-read.csv("Z:/Modelos/Zamias/finalRasterList.csv",as.is=T)
file.exists(tifs[,2])
tmplte<-raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/21112016_Zamias2/Zamia_amazonum_0_mx.tif")


colombia<-readOGR("D:/Datos/BaseLayers","mun_2011_wgs84_100k")
colRaster<-rasterize(colombia,tmplte,field=1)
p.area<-cellStats(!is.na(colRaster), sum)
omission<-rep(NA,40)
p.value<-rep(NA,40)
tss<-rep(NA,40)
inRaster<-raster(tifs[1,2])
bkg<-randomPoints(raster("//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/21112016_Zamias2/Zamia_amazonum_0_mx.tif"),n=10000)

#Compute stats

for (i in 1:40){
  print(i)
  inRaster<-raster(tifs[i,2])
  inRaster[Which(is.na(inRaster))]<-0
  inRaster[Which(is.na(tmplte))]<-NA
  plot(inRaster,main=tifs[i,1])
  spOccs<-read.csv(paste0("Z:/Modelos/Zamias/21112016_Zamias2/",tifs[i,1],".csv"),as.is=T)
  coordinates(spOccs)<-~lon+lat
  projection(spOccs)<-projection(colombia)
  ind<-!is.na(over(spOccs,colombia ))[,1]
  points(spOccs[ind,],pch=18)
  
  #Compute omission
  p<-extract(inRaster,spOccs[ind,])
  omission[i]<-100-(sum(p,na.rm=T)*100/length(na.omit(p)))
  
  #Compute p.value
 #p.area <- cellStats(inRaster, sum) / cellStats(!is.na(inRaster), sum)
  p.value[i]<-binom.test(sum(p,na.rm=T), length(na.omit(p)), p = p.area, alternative = "greater",
                         conf.level = 0.95)$p.value
  #Compute TSS
  spOccs<-read.csv(paste0("Z:/Modelos/Zamias/21112016_Zamias2/",tifs[i,1],".csv"),as.is=T)
  tss[i]<-computeTSS(inRaster,spOccs[,c("lon","lat")], bkg)
}


#Get Taxid for each species

con <- mongo(db = "records", collection = "species", 
             url = "mongodb://192.168.11.81:27017")
spNames<-sub("_"," ",tifs[,1])
taxID<-rep(NA,40)
for(i in 1:length(spNames)){
  taxID[i]<-con$find(paste0('{\"acceptedNameUsage\":\"', spNames[i], '\"}'))$taxID
}

#Write results to table

results<-data.frame(taxID=taxID,species=tifs[,1], omission, tss, p.value)
write.csv(results,"Z:/Modelos/Zamias/modelEvaluation2.csv",row.names=FALSE )
