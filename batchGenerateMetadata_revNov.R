#Correr desde R (no rstudio)

require("knitr")
require("markdown")

wd="U:/Modelos/06082014/metadata2"
files=list.files("U:/Modelos/06082014",pattern=".RData")
spNames<-gsub(".RData","",files)

for(i in 1:length(files)){
  x<-readLines("C:/Users/GIC 14/Documents/GitHub/parallelMaxent/generateMetadata.Rmd")
  y=gsub("Abarema barbouriana",spNames[i],x)
  write(y,file=paste0(wd,"/",spNames[i],".Rmd"),sep="\n") 
}

for(i in 1:length(files)){
  knit(paste0(wd,"/",spNames[i],".Rmd"),paste0(wd,"/md/",spNames[i],".md"),encoding="UTF-8")
  markdownToHTML(paste0(wd,"/md/",spNames[i],".md"),
                 paste0(wd,"/html/",spNames[i],".html"),
                 encoding="UTF-8",
                 stylesheet="C:/Users/GIC 14/Documents/GitHub/modeling/metastyle.css")
}

#Aves acuaticas
wd="U:/Modelos/TallerBogota/metadata2"
files=list.files("C:/Modelos/Acuaticas/Modelos4",pattern=".RData")
spNames<-gsub(".RData","",files)

for(i in 1:length(files)){
 x<-readLines("C:/Users/GIC 14/Documents/GitHub/parallelMaxent/generateMetadata2.Rmd")
 y=gsub("Abarema barbouriana",spNames[i],x)
 y=gsub("U:/Modelos/06082014","C:/Modelos/Acuaticas/Modelos4",y)
 write(y,file=paste0(wd,"/",spNames[i],".Rmd"),sep="\n") 
}

for(i in 1:length(files)){
  knit(paste0(wd,"/",spNames[i],".Rmd"),paste0(wd,"/md/",spNames[i],".md"),encoding="UTF-8")
  markdownToHTML(paste0(wd,"/md/",spNames[i],".md"),
                 paste0(wd,"/html/",spNames[i],".html"),
                 encoding="UTF-8",
                 stylesheet="C:/Users/GIC 14/Documents/GitHub/modeling/metastyle.css")
}

#Invasoras
wd="U:/Modelos/invasoras/metadata2"
files=list.files("U:/Modelos/invasoras",pattern=".RData")
spNames<-gsub(".RData","",files)

for(i in 1:length(files)){
  x<-readLines("C:/Users/GIC 14/Documents/GitHub/parallelMaxent/generateMetadata.Rmd")
  y=gsub("Abarema barbouriana",spNames[i],x)
  write(y,file=paste0(wd,"/",spNames[i],".Rmd"),sep="\n") 
}

for(i in 1:length(files)){
  knit(paste0(wd,"/",spNames[i],".Rmd"),paste0(wd,"/md/",spNames[i],".md"),encoding="UTF-8")
  markdownToHTML(paste0(wd,"/md/",spNames[i],".md"),
                 paste0(wd,"/html/",spNames[i],".html"),
                 encoding="UTF-8",
                 stylesheet="C:/Users/GIC 14/Documents/GitHub/modeling/metastyle.css")
}
