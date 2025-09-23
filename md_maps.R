packages <- c("haven", "ggplot2", "gapminder", "tidyverse", "dplyr", "stringr", "readxl", "tidyr","reshape2",
              "lubridate", "viridis", "haven", "janitor", "wesanderson", "cowplot", "forcats", "ggrepel", 
              "hrbrthemes","sf","tigris", "censusapi","tmap", "tidycensus", "mapview","ggmap",
              "readxl","openxlsx","fuzzyjoin","tidygeocoder","leaflet","reshape2",
              "tidytuesdayR")
invisible(lapply(packages, library, character.only = TRUE))

md <- tracts(state = "MD")
plot(md)

census_api_key("a2cccf8c3b9f897bb0afefd9138fa2b5810fe6b4",install = T)

#Maryland
md_blocks <- blocks(state = "MD",year = "2024")
plot(md_blocks["NAMELSAD"])

md_counties <- counties(state = "MD", year = "2024")
plot(md_counties["NAMELSAD"])

md_tracts <- tracts(state = "Maryland", year = "2024")
plot(md_tracts["NAMELSAD"])

md_state <- states(cb=TRUE) %>% filter(NAME == "Maryland")

#Maryland - Baltimore City 
# baltcity_tracts <- tracts(state = "Maryland", year = "2024",
#                           county = "Baltimore city")
# plot(baltcity_tracts["NAMELSAD"])

#Getting a list of the Baltimore City census tract
balt_tracts <- get_acs(geography = "tract", 
        variables = "B19013_001", 
        state = "MD", 
        county = "Baltimore city", 
        year = 2020, 
        geometry = TRUE)
head(balt_tracts)

#Pulling in neighborhood data to match against us census data. City is more accurate. 
neighborhoods <- st_read("C:/Users/rferrell/Downloads/Neighborhood Boundaries.geojson")
head(neighborhoods)
  st_write(neighborhoods, "BaltimoreCity.shp")
  
  
  crosswalk <- st_intersection(balt_tracts, neighborhoods) %>%
    mutate(area = st_area(.)) %>%
    group_by(neighborhood_name) %>% 
    summarise(
      income = weighted.mean(estimate, area, na.rm = TRUE))
  
#The code is not aligning. The st_crs(x)=st_crs(y) error has to do with map projections. 
align_crs <- 5070  #(equal-area) 
align_crs <- 4326  #(WGS84) 

#Transform both layers to the same CRS 
balttracts_crs   <- st_make_valid(st_transform(balt_tracts, align_crs))
neighborhoods_crs <- st_make_valid(st_transform(neighborhoods, align_crs))
  
# pieces <- st_intersection(
#   balttracts_crs %>% select(GEOID, estimate, geometry),
#   neighborhoods_crs %>% select(Name, geometry)) %>%
#     mutate(piece_area = as.numeric(st_area(geometry)))
#   
# crosswalk_income <- pieces %>%
#   group_by(Name) %>%
#   summarise(income_aw = weighted.mean(estimate, w = piece_area, na.rm = TRUE))
# 
# 
#   ggplot(crosswalk_income) +
#     geom_sf(aes(fill = income_aw)) +
#     scale_fill_viridis_c(labels = scales::dollar) +
#     theme_void() +
#     labs(title = "Median Household Income (area-weighted) by Baltimore Neighborhood",
#          fill = "Median income")
#   
#   ggplot(crosswalk_income) +
#     geom_sf(aes(fill = income_aw)) +
#     scale_fill_viridis_c(labels = scales::dollar) +
#     theme_void() +
#     labs(title = "Median Household Income (area-weighted) by Baltimore Neighborhood",
         # fill = "Median income")
  
