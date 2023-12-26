library(shiny)
library(leaflet)
library(leaflet.extras2)
library(leafem)
library(sf)
library(tidyverse)
library(plotly)

# Read shapefile
# geo_coplas <- st_read("data/geoinfo/rodales_stats.shp", quiet = TRUE)
geo_coplas <- read_rds("data/geoinfo/geo_coplas.rds")
geo_coplas <- st_transform(geo_coplas, crs = 4326)

# Read data 
coplas <- read_csv("data/coplas2019.csv")

# Karim 
karim <- read_csv("data/parcelas_parasit_utm.csv") |>  na.omit() 
geo_karim <- st_as_sf(karim, coords = c("UTM_x", "UTM_y"), crs = 4326)

icons <- awesomeIcons(
  icon = "tree", 
  iconColor = "white",
  library = "fa", 
  markerColor = ifelse(geo_karim$TYPE == "LOW", "orange", "green")
)

# icon = 'ios-close',
# iconColor = 'black',
# library = 'ion',

popup_rodales <- paste0(
"<strong>Código:</strong> ", geo_coplas$Codigo,
"<br><strong>Superficie (ha):</strong> ", geo_coplas$SUPERFICIE)

popup_karim <- paste0(
  "<strong>Sitio:</strong> ", geo_karim$Sitio_parasitoides,
  "<br><strong>Altitud (ha):</strong> ", geo_karim$altitud,
  "<br><strong>tipo:</strong> ", geo_karim$TYPE)

maxzoom <- 25 

mapa_base <- leaflet() |>
  addWMSTiles(
    baseUrl = "http://www.ign.es/wms-inspire/ign-base?",
    layers = "IGNBaseTodo",
    group = "Basemap",
    attribution = '© <a href="http://www.ign.es/ign/main/index.do" target="_blank">Instituto Geográfico Nacional de España</a>'
  ) |>  
  addWMSTiles("http://www.ideandalucia.es/services/toporaster10/wms?",
              layers = "toporaster10",
              group = "Topographical",
              options = WMSTileOptions(
                format = "image/png", 
                transparent = FALSE, 
                maxZoom = maxzoom),
              attribution = '<a href="http://www.juntadeandalucia.es/institutodeestadisticaycartografia" target="_blank">Instituto de Estadística y Cartografía de Andalucía</a>'
  ) |> 
  addProviderTiles("Esri.WorldImagery", 
                   group = "World Imagery (ESRI)",
                   options = providerTileOptions(maxZoom = maxzoom)) |> 
  addWMSTiles("http://www.ign.es/wms-inspire/pnoa-ma",
              layers = "OI.OrthoimageCoverage",
              group = "PNOA Máxima Actualidad",
              options = WMSTileOptions(
                format = "image/png", 
                transparent = FALSE, 
                maxZoom = maxzoom),
              attribution = 'PNOA cedido por © <a href="http://www.ign.es/ign/main/index.do" target="_blank">Instituto Geográfico Nacional de España</a>'
  ) |> 
  addMiniMap(tiles = providers$Esri.WorldTopoMap, 
             toggleDisplay = TRUE) 


ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "70%"),
  absolutePanel(top = 10, right = 10,
                selectizeInput("parcela", "Parcela",
                               choices = NULL,
                               selected = NULL,
                               options = list(
                                 'plugins' = list('remove_button'),
                                 'create' = TRUE,
                                 'persist' = TRUE,
                                 'preload' = 'window',
                                 'loadThrottle' = 300,
                                 'dropdownParent' = 'body'
                               ))),
  plotlyOutput("myplot", width = "80%", height = "30%")
  )

# Define server
server <- function(input, output, session) {
  
  shp_selected <- reactive({
    req(input$parcela)
    geo_coplas |> filter(Codigo == input$parcela)       
  })
  

  output$map <- renderLeaflet({
    mapa_base |>
      addPolygons(data = geo_coplas,
                  group = "Parcelas COPLAS",
                  fillColor = "blue",
                  layerId = ~Codigo,
                  weight = 1.2,
                  opacity = 1,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.4,
                  highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    fillColor = "white",
                    dashArray = "",
                    fillOpacity = 0.4,
                    bringToFront = TRUE
                  ), 
                  popup = popup_rodales,
                  label = ~Codigo,
                  labelOptions = labelOptions(
                    noHide = FALSE,
                    offset = c(0, 0),
                    textOnly = F,
                    style = list("color" = "black")
                  )
      ) |> 
      addAwesomeMarkers(data = geo_karim,
                 group = "Karim", 
                 popup = ~popup_karim, 
                 icon = icons) |> 
      addLayersControl(
        position = "bottomright",
        baseGroups = c("World Imagery (ESRI)", "Basemap", "Topographical","PNOA Máxima Actualidad"),
        overlayGroups = c("Karim", "Parcelas COPLAS"), 
        options = layersControlOptions(collapsed = TRUE) 
      ) |> 
      addHomeButton(ext = st_bbox(geo_coplas), "PARCELAS Coplas")
  })
  
  


  # click on polygon or select from dropdown
  observe({
    event <- input$map_shape_click
    code_selected <- if (is.null(event$id)) {
      input$parcela
    } else {
      event$id
    }
  
    # isolate({    
    #   updateSelectizeInput(session, "parcela", choices = unique(geo_coplas$Codigo),
    #                                    selected = code_selected, server = TRUE)
    #   })
    
    filtered_data <- coplas |>
      filter(code == code_selected) |>
      select(code, `1993`:`2019`) |>
      pivot_longer(-code, values_to = "infestation") |>
      mutate(year = as.numeric(str_remove(name, "X"))) |>
      dplyr::select(-name)
    
    output$myplot <- renderPlotly({
      
      validate(
        need(nrow(filtered_data) > 0, "Data insufficient for plot")
      )
      
      g <- ggplot(filtered_data, aes(x = year, y = infestation)) +
          geom_line(color = "blue") +
          geom_point() + 
          labs(
            title = paste("Evolución Temporal del Grado de Infestación. Parcela ", code_selected),
            x = "Year",
            y = "Infestation"
          ) +
          theme_bw() +  ylim(0, 5)
      
      ggplotly(g)
    })
  })
  
  

  observe({
    
    myext <- st_bbox(shp_selected()) |> as.vector()
    
    leafletProxy('map') |> 
      fitBounds(myext[1], myext[2], myext[3], myext[4])
  })

  # Dynamically update selectizeInput choices based on geo_coplas
  observe({
    updateSelectizeInput(session, "parcela", choices = unique(geo_coplas$Codigo))
  })
  
  
}

# Run the application
shinyApp(ui, server)
