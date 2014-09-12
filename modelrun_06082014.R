require(devtools)
source_url("https://raw.githubusercontent.com/LBAB-Humboldt/parallelMaxent/master/mxParallel.R")

install.packages("devtools", dependencies =T)
install.packages("dismo", dependencies =T)
install.packages("maptools", dependencies =T)
install.packages("plyr", dependencies =T)
install.packages("raster", dependencies =T)
install.packages("reshape2", dependencies =T)
install.packages("rJava", dependencies =T)
install.packages("rgdal", dependencies =T)
install.packages("rgeos", dependencies =T)
install.packages("SDMtools", dependencies =T)
install.packages("sp", dependencies =T)
install.packages("spatstat", dependencies =T)
install.packages("snowfall", dependencies =T)
install.packages("rlecuyer", dependencies =T)

#make sure to copy maxent.jar file to dismo folder

mxParallel(occ.file="Base/set16_filtered2Muni_06082014.csv",
           env.dir="Base/capas",
           env.files=c(paste0("bio_",1:19,".asc")),
           wd="Modelos/06082014",
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
           do.cut=TRUE)