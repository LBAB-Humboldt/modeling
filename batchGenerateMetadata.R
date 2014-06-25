#Correr desde R (no rstudio)

require("knitr")
require("markdown")

wd="G:/Acuaticas/Modelos4/metadata"
files=list.files("G:/Acuaticas/Modelos4",pattern=".RData")
spNames<-gsub(".RData","",files)

for(i in 1:length(spNames)){
  x<-readLines("~/GitHub/tmp/generateMetadata.Rmd")
  y=gsub("Actitis_macularius",spNames[i],x)
  write(y,file=paste0(wd,"/",spNames[i],".Rmd"),sep="\n") 
}

for(i in 1:length(spNames)){
  knit(paste0(wd,"/",spNames[i],".Rmd"),paste0(wd,"/md/",spNames[i],".md"),encoding="UTF-8")
  markdownToHTML(paste0(wd,"/md/",spNames[i],".md"),
                 paste0(wd,"/html/",spNames[i],".html"),encoding="UTF-8",stylesheet="~/tmp/metastyle.css")
}