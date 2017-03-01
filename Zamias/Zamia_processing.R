library(raster)
library(rgdal)
setwd("D:/Projects/21112016_Zamias2")
dem<-raster("D:/BaseLayers/alt.asc")
col<-readOGR("D:/BaseLayers","mun_2011_wgs84_100k")
writeRaster(col.raster,"D:/Projects/maskColombia.tif")
#Zamia amazonum
z.amazonum<-raster("Zamia_amazonum_10_mx.tif")
col.raster<-rasterize(col,z.amazonum,field=1)
new.dem<-extend(dem,z.amazonum)
extent(new.dem)<-extent(z.amazonum)
z.amazonPolyAdd<-readOGR("D:/Projects/Poligonos","Zamia_amazonum_addBelow200")
z.amazonPolyEoo<-readOGR("D:/Projects/Poligonos","Zamia_amazonum_eoo")
z.amazon_add<-rasterize(z.amazonPolyAdd,z.amazonum,field=1)
z.amazon_add[Which(is.na(z.amazon_add))]<-0
z.amazon_eoo<-rasterize(z.amazonPolyEoo,z.amazonum)
z.amazonum2<-z.amazonum*z.amazon_eoo+z.amazon_add
z.amazonum2<-col.raster*z.amazonum2
z.amazonum2[Which(z.amazonum2>0)]<-1
z.amazonum3<-z.amazonum2*(new.dem<=200)
writeRaster(z.amazonum3,"D:/Projects/Consenso/Zamia_amazonum_con1.tif")
writeRaster(z.amazonum2*(new.dem<=500),"D:/Projects/Consenso/Zamia_amazonum_con2.tif")
#Zamia chigua
z.chigua<-raster("Zamia_chigua_0_mx.tif")
z.chigua_eoo<-readOGR("D:/Projects/Poligonos","Zamia_chigua_eoo")
z.chigua.eoo<-rasterize(z.chigua_eoo,z.chigua)
z.chigua2<-z.chigua*z.chigua.eoo
writeRaster(z.chigua2,"D:/Projects/Consenso/Zamia_chigua_con.tif")
#Zamia disodon
z.disodon<-raster("Zamia_disodon_0_mx.tif")
z.disodon_eoo<-readOGR("D:/Projects/Poligonos","Zamia_disodon_eoo")
z.disodon.eoo<-rasterize(z.disodon_eoo,z.disodon)
z.disodon2<-z.disodon*z.disodon.eoo
writeRaster(z.disodon2,"D:/Projects/Consenso/Zamia_disodon_con.tif")
#Zamia encephalartoides
z.encepha<-raster("Zamia_encephalartoides_0_mx.tif")
z.encepha_eoo<-readOGR("D:/Projects/Poligonos","Zamia_encephalartoides_eoo")
z.encepha.eoo<-rasterize(z.encepha_eoo,z.encepha)
z.encepha2<-z.encepha*z.encepha.eoo
writeRaster(z.encepha2,"D:/Projects/Consenso/Zamia_encephalartoides_con.tif")
#Zamia huilensis
z.huilensis<-raster("Zamia_huilensis_0_mx.tif")
z.huilensis_eoo<-readOGR("D:/Projects/Poligonos","Zamia_huilensis_eoo")
z.huilensis.eoo<-rasterize(z.huilensis_eoo,z.huilensis)
z.huilensis2<-z.huilensis*z.huilensis.eoo
writeRaster(z.huilensis2,"D:/Projects/Consenso/Zamia_huilensis_con.tif")
#Zamia hymenophyllidia
z.hymeno<-raster("Zamia_hymenophyllidia_0_mx.tif")
z.hymeno_eoo<-readOGR("D:/Projects/Poligonos","Zamia_hymenophyllidia_eoo")
z.hymeno.eoo<-rasterize(z.hymeno_eoo,z.hymeno)
z.hymeno2<-z.hymeno*z.hymeno.eoo
z.hymeno2<-z.hymeno2*col.raster
writeRaster(z.hymeno2,"D:/Projects/Consenso/Zamia_hymenophyllidia_con.tif")
#Zamia incognita
z.incognita<-raster("Zamia_incognita_10_mx.tif")
z.incognita_eoo<-readOGR("D:/Projects/Poligonos","Zamia_incognita_eoo")
z.incognita.eoo<-rasterize(z.incognita_eoo,z.incognita)
z.incognita2<-z.incognita*z.incognita.eoo
z.incognita3<-z.incognita2*(new.dem<=1200)
writeRaster(z.incognita3,"D:/Projects/Consenso/Zamia_incognita_con.tif")

#Zamia manicata
z.manicata<-raster("Zamia_manicata_0_mx.tif")
z.manicata_eoo<-readOGR("D:/Projects/Poligonos","Zamia_manicata_eoo")
z.manicata.eoo<-rasterize(z.manicata_eoo,z.manicata)
z.manicata2<-z.manicata*z.manicata.eoo
z.manicata3<-z.manicata2*col.raster
writeRaster(z.manicata3,"D:/Projects/Consenso/Zamia_manicata_con.tif")

#Zamia melanorrachis
z.melano<-raster("Zamia_melanorrhachis_0_mx.tif")
z.melano_eoo<-readOGR("D:/Projects/Poligonos","Zamia_melanorrhachis_eoo")
z.melano.eoo<-rasterize(z.melano_eoo,z.melano)
z.melano2<-z.melano*z.melano.eoo
writeRaster(z.melano2,"D:/Projects/Consenso/Zamia_melanorrhachis_con.tif")

#Zamia muricata
z.muricata<-raster("D:/Projects/21112016_Zamias/Zamia_muricata_0_bc.tif")
z.muricata_eoo<-readOGR("D:/Projects/Poligonos","Zamia_muricata_eoo_bc")
z.muricata.eoo<-rasterize(z.muricata_eoo,z.muricata)
z.muricata2<-z.muricata*z.muricata.eoo
writeRaster(z.muricata2,"D:/Projects/Consenso/Zamia_muricata_con.tif")

#Zamia obliqua
z.obliqua<-raster("Zamia_obliqua_10_mx.tif")
z.obliqua_eoo<-readOGR("D:/Projects/Poligonos","Zamia_obliqua_eoo")
z.obliqua.eoo<-rasterize(z.obliqua_eoo,z.obliqua)
z.obliqua2<-z.obliqua*z.obliqua.eoo
z.obliqua3<-z.obliqua2*col.raster
writeRaster(z.obliqua3,"D:/Projects/Consenso/Zamia_obliqua_con.tif")

#Zamia pyrophylla
z.pyrophylla<-raster("Zamia_pyrophylla_10_mx.tif")
z.pyrophylla_eoo<-readOGR("D:/Projects/Poligonos","Zamia_pyrophylla_eoo")
z.pyrophylla.eoo<-rasterize(z.pyrophylla_eoo,z.pyrophylla)
z.pyrophylla2<-z.pyrophylla*z.pyrophylla.eoo
writeRaster(z.pyrophylla2,"D:/Projects/Consenso/Zamia_pyrophylla_con.tif")

#Zamia roezli
z.roezlii<-raster("Zamia_roezlii_0_mx.tif")
z.roezlii_eoo<-readOGR("D:/Projects/Poligonos","Zamia_roezlii_eoo")
z.roezlii.eoo<-rasterize(z.roezlii_eoo,z.roezlii)
z.roezlii2<-z.roezlii*z.roezlii.eoo
writeRaster(z.roezlii2,"D:/Projects/Consenso/Zamia_roezlii_con.tif")

#Zamia tolimensis
z.tolimensis<-raster("Zamia_tolimensis_10_mx.tif")
z.tolimensis_eoo<-readOGR("D:/Projects/Poligonos","Zamia_tolimensis_eoo")
z.tolimensis.eoo<-rasterize(z.tolimensis_eoo,z.tolimensis)
z.tolimensis2<-z.tolimensis*z.tolimensis.eoo
z.tolimensis3<-z.tolimensis2*(new.dem<=2200)
writeRaster(z.tolimensis3,"D:/Projects/Consenso/Zamia_tolimensis_con.tif")

#Zamia ulei
z.ulei<-raster("Zamia_ulei_0_mx.tif")
z.ulei_eoo<-readOGR("D:/Projects/Poligonos","Zamia_ulei_eoo")
z.ulei.eoo<-rasterize(z.ulei_eoo,z.ulei)
z.ulei2<-z.ulei*z.ulei.eoo
z.ulei3<-z.ulei2*col.raster
writeRaster(z.ulei3,"D:/Projects/Consenso/Zamia_ulei_con.tif")
#Zamia amplifolia
z.amplifolia<-read.csv("Zamia_amplifolia.csv",as.is=T)
z.amplif_ch<-convHull(cbind(z.amplifolia$lon,z.amplifolia$lat))
z.amplif.ch<-predict(z.amplif_ch,new.dem)
z.amplif.ch2<-z.amplif.ch*(new.dem<=500)
writeRaster(z.amplif.ch2,"D:/Projects/Consenso/Zamia_amplifolia_con.tif")

#Zamia montana
z.montana<-read.csv("Zamia_montana.csv",as.is=T)
crs(new.dem)<-"+proj=longlat +ellps=WGS84 +datum=WGS84"
proj.crs<-"+proj=utm +zone=18 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
z.montana2<-ChMap(z.montana,new.dem,10000,proj.crs)
writeRaster(z.montana2,"D:/Projects/Consenso/Zamia_montana_con.tif")

#Zamia restrepoi
z.restrepoi<-read.csv("Zamia_restrepoi.csv",as.is=T)
z.restrepoi2<-ChMap(z.restrepoi,new.dem,10000,proj.crs)
writeRaster(z.restrepoi2,"D:/Projects/Consenso/Zamia_restrepoi_con.tif")

#Zamia wallisi
z.wallisii<-read.csv("Zamia_wallisii.csv",as.is=T)
z.wallisii2<-ChMap(z.wallisii,new.dem,10000,proj.crs)
z.wallisii3<-z.wallisii2*(new.dem>=900)*(new.dem<=1500)
writeRaster(z.wallisii3,"D:/Projects/Consenso/Zamia_wallisii_con.tif")

#Zamia oligodonta
z.oligodonta<-read.csv("Zamia_oligodonta.csv",as.is=T)
z.oligodonta2<-ChMap(z.oligodonta,new.dem,50000,proj.crs)
z.oligodonta3<-z.oligodonta2*(new.dem>=1500)*(new.dem<=2000)
z.oligodonta_eoo<-readOGR("D:/Projects/Poligonos","Zamia_oligodonta")
z.oligodonta.eoo<-rasterize(z.oligodonta_eoo,z.oligodonta3)
z.oligodonta4<-z.oligodonta3*z.oligodonta.eoo
writeRaster(z.oligodonta4,"D:/Projects/Consenso/Zamia_oligodonta_con.tif")

#Nivel2
rm(list=ls())
setwd("D:/Projects/Consenso")
#Zamia amazonum
z.amazonum1<-raster("Zamia_amazonum_con1.tif")
z.amazonum2<-raster("Zamia_amazonum_con2.tif")
z.amazonum_veg<-raster("D:/Projects/vegMasks/Zamia amazonum.tif")
z.amazonum_veg<-extend(z.amazonum_veg,z.amazonum1)
extent(z.amazonum_veg)<-extent(z.amazonum1)
z.amazonum_n2_1<-z.amazonum_veg*z.amazonum1
z.amazonum_n2_2<-z.amazonum_veg*z.amazonum2
writeRaster(z.amazonum_n2_1,"D:/Projects/Nivel2/Zamia_amazonum_veg1.tif")
writeRaster(z.amazonum_n2_2,"D:/Projects/Nivel2/Zamia_amazonum_veg2.tif")

#Zamia amplifolia
z.amplif<-raster("Zamia_amplifolia_con.tif")
z.amplif_veg<-raster("D:/Projects/vegMasks/Zamia amplifolia.tif")
z.amplif_veg<-extend(z.amplif_veg,z.amplif)
extent(z.amplif_veg)<-extent(z.amplif)
z.amplif_n2<-z.amplif_veg*z.amplif
writeRaster(z.amplif_n2,"D:/Projects/Nivel2/Zamia_amplifolia_veg.tif")

#Zamia chigua
z.chigua<-raster("Zamia_chigua_con.tif")
z.chigua_veg<-raster("D:/Projects/vegMasks/Zamia chigua.tif")
z.chigua_veg<-extend(z.chigua_veg,z.chigua)
extent(z.chigua_veg)<-extent(z.chigua)
z.chigua_n2<-z.chigua_veg*z.chigua
writeRaster(z.chigua_n2,"D:/Projects/Nivel2/Zamia_chigua_veg.tif")

#Zamia disodon
z.disodon<-raster("Zamia_disodon_con.tif")
z.disodon_veg<-raster("D:/Projects/vegMasks/Zamia disodon.tif")
z.disodon_veg<-extend(z.disodon_veg,z.disodon)
extent(z.disodon_veg)<-extent(z.disodon)
z.disodon_n2<-z.disodon_veg*z.disodon
writeRaster(z.disodon_n2,"D:/Projects/Nivel2/Zamia_disodon_veg.tif")

#Zamia encephalartoides
z.encephalartoides<-raster("Zamia_encephalartoides_con.tif")
z.encephalartoides_veg<-raster("D:/Projects/vegMasks/Zamia encephalartoides.tif")
z.encephalartoides_veg<-extend(z.encephalartoides_veg,z.encephalartoides)
extent(z.encephalartoides_veg)<-extent(z.encephalartoides)
z.encephalartoides_n2<-z.encephalartoides_veg*z.encephalartoides
writeRaster(z.encephalartoides_n2,"D:/Projects/Nivel2/Zamia_encephalartoides_veg.tif")

#Zamia huilensis
nivel2<-function(inRaster,vegRaster,outRaster){
  inRaster<-raster(inRaster)
  vegRaster<-raster(paste0("D:/Projects/vegMasks/",vegRaster))
  vegRaster<-extend(vegRaster,inRaster)
  extent(vegRaster)<-extent(inRaster)
  result<-vegRaster*inRaster
  writeRaster(result,paste0("D:/Projects/Nivel2/",outRaster))
}
nivel2("Zamia_huilensis_con.tif","Zamia huilensis.tif","Zamia_huilensis_veg.tif")
nivel2("Zamia_hymenophyllidia_con.tif","Zamia hymenophyllidia.tif","Zamia_hymenophyllidia_veg.tif")
nivel2("Zamia_incognita_con.tif","Zamia incognita.tif","Zamia_incognita_veg.tif")
nivel2("Zamia_manicata_con.tif","Zamia manicata.tif","Zamia_manicata_veg.tif")
nivel2("Zamia_melanorrhachis_con.tif","Zamia melanorrhachis.tif","Zamia_melanorrhachis_veg.tif")
nivel2("Zamia_montana_con.tif","Zamia montana.tif","Zamia_montana_veg.tif")
nivel2("Zamia_muricata_con.tif","Zamia muricata.tif","Zamia_muricata_veg.tif")
nivel2("Zamia_obliqua_con.tif","Zamia obliqua.tif","Zamia_obliqua_veg.tif")
nivel2("Zamia_oligodonta_con.tif","Zamia oligodonta.tif","Zamia_oligodonta_veg.tif")
nivel2("Zamia_pyrophylla_con.tif","Zamia pyrophylla.tif","Zamia_pyrophylla_veg.tif")
nivel2("Zamia_restrepoi_con.tif","Zamia restrepoi.tif","Zamia_restrepoi_veg.tif")
nivel2("Zamia_roezlii_con.tif","Zamia roezlii.tif","Zamia_roezlii_veg.tif")
nivel2("Zamia_tolimensis_con.tif","Zamia tolimensis.tif","Zamia_tolimensis_veg.tif")
nivel2("Zamia_ulei_con.tif","Zamia ulei.tif","Zamia_ulei_veg.tif")
nivel2("Zamia_wallisii_con.tif","Zamia wallissi.tif","Zamia_wallisii_veg.tif")

#Managing layers
allZamias<-readOGR("D:/Projects/shp","all_zamias")
spList<-unique(allZamias@data$species)
for(i in 1:length(spList)){
  out.shp<-allZamias[allZamias@data$species==spList[i],]
  writeOGR(out.shp,"D:/Projects/shp",spList[i],"ESRI Shapefile")
}

#Set 0 to NA
file.list<-list.files("D:/Projects/Consenso","*.tif$")
setwd("D:/Projects/Consenso")
for(i in 1:length(file.list)){
  in.raster<-raster(file.list[i])
  in.raster[in.raster==0]<-NA
  writeRaster(in.raster,paste0("D:/Projects/Consenso_NA/",file.list[i]))
}

file.list<-list.files("D:/Projects/Nivel2","*.tif$")
setwd("D:/Projects/Nivel2")

for(i in 1:length(file.list)){
  in.raster<-raster(file.list[i])
  in.raster[in.raster==0]<-NA
  writeRaster(in.raster,paste0("D:/Projects/Nivel2_NA/",file.list[i]),NAflag=-9999,overwrite=T)
}

#Corregir Zamia montana
setwd("D:/Projects/Consenso_NA")
zmontana<-raster("Zamia_montana_con.tif")
zmontana2<-zmontana*(new.dem>=1500)*(new.dem<=2000)
zmontana2[zmontana2==0]<-NA
writeRaster(zmontana2,"Zamia_montana_con2.tif",NAflag=-9999,overwrite=T)
nivel2("Zamia_montana_con2.tif","Zamia montana.tif","Zamia_montana_veg2.tif")
