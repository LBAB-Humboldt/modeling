#Run models
require(devtools)
source_url("https://raw.githubusercontent.com/LBAB-Humboldt/parallelMaxent/master/mxParallel.R")

mxParallel(occ.file="registros_mod_jv.csv",
           env.dir="Capas",
           env.files=c(paste0("bio_",1:19,".asc")),
           wd="Modelos",
           dist=1415,
           bkg.aoi = "extent",
           bkg.type="random", 
           n.bkg = 10000, 
           sample.bkg = NULL,
           optimize.lambda=FALSE,
           lambda=1,
           folds=5, 
           do.eval=TRUE,
           n.cpu=16,
           mxnt.args=c("autofeature=FALSE","linear=TRUE","quadratic=TRUE","product=FALSE","hinge=TRUE","threshold=FALSE",
                       "extrapolate=FALSE","doclamp=TRUE","addsamplestobackground=TRUE"), 
           do.threshold=TRUE, 
           raw.threshold=c(0,10,20,30), 
           do.cut=FALSE)

#Create PNG
rm(list=ls())
in.folder = "/home/cas/Jorge/Modelos"
fill = rgb(193,140,40,maxColorValue=255)
sp.list<-list.files("/home/cas/Jorge/Modelos","*.tif")

require(snowfall)
sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(sp.list, convert2PNG, in.folder=in.folder, fill=fill, add.trans=TRUE)
sfStop()

#Create KMZ
fileList<-list.files("/home/cas/Jorge/Modelos/KMZ","*.kml")

spNames<-sapply(strsplit(fileList,"\\."),"[",1)

for(i in 1:length(spNames)){
  print(spNames[i])
  zip(paste0("/home/cas/Jorge/Modelos/KMZ/",spNames[i],".kmz"),
      files=c(paste0("/home/cas/Jorge/Modelos/KMZ/",spNames[i],".kml"),
              paste0("/home/cas/Jorge/Modelos/KMZ/",spNames[i],".png")),
      flags="-j")
}

#Run metadata on local machine
require("knitr")
require("markdown")

wd="D:/Projects/Invasoras/Modelos/metadata"
dir.create(paste0(wd,"/md"))
dir.create(paste0(wd,"/html"))
files=list.files("D:/Projects/Invasoras/Modelos",pattern=".RData")
spNames<-gsub(".RData","",files)

for(i in 1:length(spNames)){
  x<-readLines("C:/Users/GIC 14/Documents/GitHub/parallelMaxent/generateMetadata.Rmd")
  y=gsub("Abarema barbouriana",spNames[i],x)
  write(y,file=paste0(wd,"/",spNames[i],".Rmd"),sep="\n") 
}

for(i in 1:length(spNames)){
  knit(paste0(wd,"/",spNames[i],".Rmd"),paste0(wd,"/md/",spNames[i],".md"),encoding="UTF-8")
  markdownToHTML(paste0(wd,"/md/",spNames[i],".md"),
                 paste0(wd,"/html/",spNames[i],".html"),
                 encoding="UTF-8",
                 stylesheet="C:/Users/GIC 14/Documents/GitHub/modeling/metastyle.css")
}