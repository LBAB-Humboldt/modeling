#Correr desde R (no rstudio)

require("knitr")
require("markdown")

wd="U:/Modelos/06082014/metadata"
files=list.files("U:/Modelos/06082014",pattern=".RData")
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