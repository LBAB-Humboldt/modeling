fill=rgb(193,140,40,maxColorValue=255)
in.folder="~/Modelos/06082014"
sp.list=list.files(in.folder, pattern="*_0.tif|*_10.tif|*_20.tif|*_30.tif")
require(devtools)
source_url("https://raw.githubusercontent.com/LBAB-Humboldt/parallelMaxent/master/convert2PNG.R")
require(snowfall)
sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(sp.list, convert2PNG, in.folder=in.folder, fill=fill, add.trans=TRUE)
sfStop()
