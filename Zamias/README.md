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

###//192.168.11.113/Lab_biogeografia2/Modelos/Zamias/Consenso_NA
Modelos procesados a partir de los anteriores, en los que los 0s fueron cambiados a NA

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

