# Visualización de la evolución de la procesionaria en los pinares de Andalucía

[![DOI](https://zenodo.org/badge/734796915.svg)](https://zenodo.org/doi/10.5281/zenodo.10433224)


Este repositorio contiene una shiny app en el que se muestra un mapa interactivo con la distribución de las parcelas de seguimiento del grado de infestación de la procesionaria del pino en los pinares de Andalucía. Para cada una de las parcelas se muestra además un gráfico dinámico con la evolución del grado de infestación de cada parcela desde 1993. 

Los datos usados para desarrollar esta aplicación proceden de Ros-Candeira et al. (2019)[^1]. 

[^1]: Ros-Candeira, A., Pérez-Luque, A.J., Suárez-Muñoz, M., Bonet-García, F.J., Hódar, J.A., Giménez de Azcárate, F. & Ortega-Díaz, E. 2019. Dataset of occurrence and incidence of pine processionary moth in Andalusia, south Spain. ZooKeys, 852: 125–136. doi: [10.3897/zookeys.852.28567](https://doi.org/10.3897/zookeys.852.28567)

## Despliegue
En esta versión, existen dos opciones para ejecutar la app: 

- [Online](http://vlab.iecolab.es/ajpelu/spatial_coplas_ppm). Tenemos desplegada la app en el siguiente enlace http://vlab.iecolab.es/ajpelu/spatial_coplas_ppm

- Local: 
    
    - Descarga el repositorio. 
    - Abre el proyecto con Rstudio
    - Ejecuta el archivo `app.R` 

## Funcionamiento

1. Selecciona el código de la parcela en el selector. También puedes navegar por el mapa y seleccionar la parcela espacialmente. 
2. Para obtener el gráfico de la evolución del grado de infestación en cada parcela, simplemente clica en la parcela y el gráfico aparecerá en el panel inferior. 
3. En la parte derecha del mapa aparece un selector de mapas base diferentes: satélite, mapa base, topográfico, etc. 

### Developer: 
- [**Antonio J. Pérez-Luque**](https://github.com/ajpelu) <a href="https://orcid.org/0000-0002-1747-0469" target="orcid.widget"> <img src="https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png" alt="ORCID logo" width="16" height="16"/></a> 

### Como citar: 
Pérez-Luque, AJ (2023). Visualización de la evolución de la procesionaria en los pinares de Andalucía. Versión 0.1. https://github.com/ajpelu/spatial_coplas_ppm. doi: [10.5281/zenodo.10433224](https://zenodo.org/doi/10.5281/zenodo.10433224)




