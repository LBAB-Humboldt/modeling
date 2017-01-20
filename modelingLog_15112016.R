occs<-read.csv("initial_occurrences_plusRoman.csv",as.is=T)

#Begin modeling
wd<-"/home/rstudio/test/Modelos/15112016_Herps"
env.dir="/home/rstudio/test/baseData/Capas"
env.files<-paste0("bio_",c(1,2,3,4,12,15,18),".asc")
occ.file<-occs
sp.col <- "species"
id.col <- "id"
dist <- 1000 # se escogio esta distancia en lugar de 1414.2 
#porque en la generacion de los csv originales x Ivan ya se 
#habia tenido en cuenta dicha distancia. Esta se escoge porque 
#hay nuevos registros que pueden quedar cerca de los ya existentes
#pero por la aleatorización del procedimiento de identificacion de
#vecinos no seria apropiado volver a escoger la distancia de 1414.2
#que puede eliminar registros que quedaron en la aleatorizacion inicial.
n.bkg=10000
bias.raster<-raster("herps_avg.asc")
mxnt.args=c("autofeature=FALSE","extrapolate=FALSE","doclamp=TRUE","addsamplestobackground=TRUE")
raw.threshold<-c(0,10,20,30)
folds <-5
do.threshold<-TRUE
buffer<-150000
proj.crs<-"+proj=utm +zone=18 +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
n.cpu<-15
as.is=TRUE
bmWorkflow(wd, env.dir, env.files, occ.file, sp.col, id.col, dist, n.bkg, bias.raster, 
           mxnt.args, do.treshold, raw.threshold, folds,buffer,proj.crs,ncpu,as.is)
