
library(sf)
library(tidyverse)
library(rnaturalearth)

# see https://dominicroye.github.io/en/2019/calculating-the-distance-to-the-sea-in-r/ 
# Read data 
coplas <- read_csv("data/coplas2019.csv")

karim <- read_csv("data/parcelas_parasit_utm.csv") 
geo_karim <- st_as_sf(karim, coords = c("UTM_x", "UTM_y"), crs = 4326)

geo_karimed50 <- st_transform(geo_karim, 23030)


spain <- ne_countries(scale = 10, country = "Spain", returnclass = "sf")
spain_ed50 <- st_transform(spain, 23030)

plot(st_geometry(spain_ed50))
plot(st_geometry(geo_karimed50), pch = 3, col = 'red', add = TRUE)



spain_ed50_line <- st_cast(spain_ed50, "MULTILINESTRING")

#calculation of the distance between the coast and our points
dist <- data.frame(dist_to_coast = as.vector(t(round(st_distance(spain_ed50_line, geo_karimed50),2))))

# Export 
geo <- geo_karimed50 |> bind_cols(dist)
st_write(geo, "data/geoinfo/dist_to_coast.shp", append = FALSE)

# to csv 
geo |> st_drop_geometry() |> write_csv("data/geoinfo/dist_to_coast.csv")





