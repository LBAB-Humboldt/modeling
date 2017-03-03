#Métodos empleados para el modelamiento de Zamias

##Registros
Los registros empleados en el modelamiento de las 20 especies de Zamias que ocurren en el territorio continental colombiano  fueron provistos por la moderadora del grupo biomodelos de Zamias y han sido revisados taxonómica y geográficamente para asegurar su calidad. Para el modelamiento se ignoraron los registros a menos de 1.41 km entre si.

##Capas ambientales
Se utilizaron las capas "bio_1", "bio_2", "bio_3", "bio_4", "bio_12", "bio_15" y "bio_18" provenientes de la versión 2 (beta) de WorldClim http://worldclim.org/version2.

##Área de estudio
El área de estudio comprende la ventana -83, -60, -14, 13  (xmin, xmax, ymin, ymax).

##Background
Los datos de fondo (10000 pares de coordenadas, para Maxent), fueron muestreados para el área de estudio utilizando como superficie de probabilidad una capa de sesgo de muestreo para plantas, desarrollada con datos de GBIF para todas las especies del reino Plantae registradas en la ventana de estudio y usando como predictores las variables densidad poblacional humana (año 2000), distancia en kilómetros a la carretera más cercana y distancia en kilómetros al rio navegable más cercano.

##Modelamiento
Para el modelamiento se utilizaron 3 métodos de acuerdo a la cantidad de registros disponibles: (1-4 registros): polígono mínimo convexo y (5+ registros): Maxent. Sólo para una especie, *Zamia muricata*, se utilizó Bioclim.

En Maxent se utilizó clamping y se consideraron features de tipo lineal, cuadrático y hinge. Para optimizar la combinación de multiplicador de regularización y features, se utilizó el paquete `ENMeval`, con método de validación `checkerboard1` y 5 folds, y se escogió el modelo con mayor valor de AUC.Una vez fue encontrada la combinación de features y regularización que maximizaban el desempeño del modelo, se volvió a correr el modelo usando la totalidad de los registros con la configuración óptima para producir un modelo final. En Bioclim se corrieron los modelos con validación cruzada de 5 folds para su evaluación con AUC pero los modelos finales también usan todos los registros disponibles.

A partir de los modelos continuos se generaron 4 modelos binarios usando como umbrales los percentiles 0, 10, 20 y 30 de las idoneidades de los registros empleados en el desarrollo del modelo. Cada modelo binario fue validado independientemente usando una validación cruzada de 5 folds y True Skill Statistic como estadístico de desempeño.

El script con el flujo de trabajo de modelamiento se encuentra disponible en https://github.com/LBAB-Humboldt/BMModelWF/blob/master/modelingWorkflow.R

##Resultados modelamiento
Los métodos de modelamiento empleados para cada especie son: 

Especie | Método
- | -
Zamia amazonum | Maxent
Zamia amplifolia | Maxent
Zamia chigua | Maxent
Zamia disodon	| Maxent
Zamia encephalartoides | Maxent
Zamia huilensis |	Maxent
Zamia hymenophyllidia |	Maxent
Zamia incognita	| Maxent
Zamia manicata | Maxent
Zamia melanorrhachis | Maxent
Zamia montana	| Convex Hull
Zamia muricata | Bioclim
Zamia obliqua	| Maxent
Zamia oligodonta | Convex Hull
Zamia pyrophylla | Maxent
Zamia restrepoi | Convex Hull
Zamia roezlii	| Maxent
Zamia tolimensis	| Maxent
Zamia ulei	| Maxent
Zamia wallisii	| Convex Hull

##Aportes expertos
En conjunto con Cristina López-Gallego y también Dairon Cárdenas en el caso de Z. amazonum, Z. hymenophyllidia y Z. ulei se definieron los métodos de modelamiento, umbrales y  ediciones pertinentes para cada especie. Este es un resumen de las ediciones incorporadas

Especie|Método|Umbral|Ediciones
-------|------|------|---------
*Zamia amazonum*|Maxent|10|Recortar por eoo y elevaciones por encima de 300m
*Zamia amplifolia*|Convex Hull|NA|Recortar elevaciones por encima de 500
*Zamia chigua*|Maxent|0|Recortar por eoo
*Zamia disodon*|Maxent|0|Recortar por eoo
*Zamia encephalartoides*|Maxent|0|Recortar por eoo
*Zamia huilensis*|Maxent|0|Recortar por eoo
*Zamia hymenophyllidia*|Maxent|0|Recortar por eoo. Eliminar predicciones al norte del Río Apaporis.
*Zamia incognita*|Maxent|10|Recortar por eoo manteniendo sólo elevaciones por debajo de 1200
*Zamia manicata*|Maxent|0|Recortar por eoo. Al norte del rio Pavarando y Salaqui
*Zamia melanorrhachis*|Maxent|0|Recortar por eoo
*Zamia montana*|Buffer 10km|NA|Restringir prediccion al rango de 1500 a 2000
*Zamia muricata*|Bioclim|0|Recortar por eoo
*Zamia obliqua*|Maxent|10|Recortar por poligono que corta en la parte norte en la Serrania de Abibe
*Zamia oligodonta*|Buffer 50km|NA|"Restringir a la vertiente occidental de la cordillera occidental, entre los 1500 y 2000m"
*Zamia pyrophylla*|Maxent|10|Recortar por poligono que sigue el margen oriental del Rio Atrato y limita al sur con Rio San Juan
*Zamia restrepoi*|Convex Hull 10km|NA
*Zamia roezlii*|Maxent|0|Recortar por eoo al sur del Rio Baudó
*Zamia tolimensis*|Maxent|10|Recortar por eoo y mantener lo que hay por debajo de 2200m.
*Zamia ulei*|Maxent|0|Recortar por eoo
*Zamia wallisii*|Buffer 50km|NA|Retener elevaciones entre 900-1500m.

Los polígonos de recorte fueron generados desplegando los modelos en ArcGIS.