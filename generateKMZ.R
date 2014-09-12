fileList<-list.files("~/Modelos/06082014/KMZ", pattern="*.kml")

spNames<-sapply(strsplit(fileList,"\\."),"[",1)

for(i in 1:length(spNames)){
  print(spNames[i])
  zip(paste0("/home/gic/Modelos/06082014/KMZ/",spNames[i],".kmz"),
      files=c(paste0("/home/gic/Modelos/06082014/KMZ/",spNames[i],".kml"),
              paste0("/home/gic/Modelos/06082014/PNG/",spNames[i],".png")),
      flags="-j")
}