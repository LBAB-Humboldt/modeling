#Historial procesamiento modelos de Zamias

Nota: los archivos de este procesamiento fueron manejados en D:/Projects/Zamias (GIC14), la cuenta de Dropbox y computador personal de Jorge Velásquez. En la actualidad la mayoría de archivos deben estar en //192.168.11.113/Lab_biogeografia2/Modelos/Zamias.

Los modelos fueron desarrollados usando el script `1112016_Zamias.R`, disponible en este repositorio GitHub. A partir de este script se generaron dos conjuntos de Modelos: 

###//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/21112016_Zamias:
Son modelos que se corrieron con tres tipos de métodos: convex hull (1-4 registros, bioclim (5-9 registros) y maxent (>9 registros)

###//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/21112016_Zamias2:
Son modelos que se corrieron con dos tipos de métodos: convex hull (1-4) registros y maxent (>4 registros). Con excepción de *Zamia muricata*, la mayoría de modelos fueron procesados a partir de este folder.

Los siguientes archivos fueron resultado del procesamiento de alguno de los modelos disponibles en los dos folders anteriores.

###//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso
Modelos resultante despues de procesar los aportes disponibles en el archivo `Estado modelamiento Zamias2.xlsx` pestaña, Revisión final.

> Modelos editados de forma manual en ArcGIS, de acuerdo al archivo //192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Correos Dairon.pdf, que corresponde a la copia de los correos entre Jorge Velásquez, Cristina López-Gallego y Dairon Cárdenas. Allí, Dairon sugiere las siguientes ediciones para las especies:

*Zamia amazonum: cortar el modelo por la cota altitudinal de 300 m.s.n.m. Para esta especie encontramos entonces cuatro archivos:
+**Zamia_amazonum_con1.tif**: corresponde al modelo nivel 1 de la especie cortado por una cota altitudinal de 200 m.s.n.m).
+**Zamia_amazonum_con2.tif**: corresponde al modelo nivel 1 de la especie cortado por una cota altitudinal de 500 m.s.n.m).
+**Zamia_amazonum_con3.tif**: sigue la edición propuesta por Dairon Cárdenas.

*Zamia hymenophyllidia: descartar la parte del modelo hacia el norte del rio Apaporis. Para esta especie encontramos entonces tres archivos:
+**Zamia_hymenophyllidia_con.tif**: corresponde al modelo nivel 1.
+**Zamia_hymenophyllidia_con2.tif**: sigue la edición propuesta por Dairon Cárdenas, utilizando la máscara  //192.168.11.113/Lab_biogeografia2/Modelos/Zamias/rio apaporis/mask_apaporis.shp.

###//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso_NA
Modelos procesados a partir de los anteriores, en los que los 0s fueron cambiados a NA

### `Arreglo_extent.R`
Tiene el log para asignar el extent correcto a los modelos.

> Modelos a los que se le corrigió el extent mediante el script `Arreglo_extent.R`:

* Zamia amazonum: el archivo resultante es **Zamia_amazonum_con4.tif**.

* Zamia hymenophyllidia: el archivo resultante es **Zamia_hymenophyllidia_con3.tif**.

###//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Nivel2
Modelos Nivel 2 procesados a partir de los modelos consenso y vegMasks, generadas a partir de la información en `Estado modelamiento Zamias2.xlsx` pestaña, Variables ecológicas.

###//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Nivel2_NA
Modelos procesados a partir de los anteriores, en los que los 0s fueron cambiados a NA

###//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Poligonos
Shapes de aporte de experto. El sufijo EOO corresponde a un polígono de recorte, y el sufijo add a un polígono de agregar

###//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Shp
Shapes de datos de ocurrencia para todas las especies

###//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/vegMasks
Mascaras de vegetacion

### `Zamia_processing.R`
Tiene el log de procesamiento de los aportes de experto.

### Estado modelamiento Zamias2.xlsx
Archivo con el estado general de procesamiento

###`convert2PNG_zamias.R`
Tiene el log de procesamiento para convertir los archivos .tif (consenso y nivel 2) de los modelos a archivos .png que son publicados a través de BioModelos.

### //192.168.11.113/Lab_biogeografia2/BioModelos/Zamias_2016/Consenso
