library(dplyr)
library(sf)
library(XML)
library(readr)

source("./functions/generateVISTAActsAndLeg.R")
source("./functions/generatePopulationXML.R")

echo<- function(msg) {
  cat(paste0(as.character(Sys.time()), ' | ', msg))  
}

printProgress<-function(row, total_row, char)  {
  if((row-10)%%500==0) echo('')
  cat('.')
  if(row%%100==0) cat('|')
  if(row%%500==0) cat(paste0(char,' ', row, ' of ', total_row, '\n'))
}

# Control Variables:

sample_size <- 0.1

# REading inputs
trips <- read_csv("./data/vista/T_VISTA12_16_SA1_V1.csv") 
# Filtering out outside Victoria stops and simplifying the place and mode tags
trips <- trips %>% 
  mutate(ORIGPLACE1_2 = if_else(is.na(ORIGPLACE1), true = "other", 
                                false = if_else(ORIGPLACE1 == "Accommodation" ,true = "home", 
                                                false = if_else(ORIGPLACE1 == "Workplace", true = "work", 
                                                                false = if_else(ORIGPLACE1 == "Place of Education", true = "edu", 
                                                                                false = if_else(ORIGPLACE1 == "Shops", true = "shop", 
                                                                                                false = "other")))))) %>% 
  mutate(DESTPLACE1_2 = if_else(is.na(ORIGPLACE1), true = "other", 
                                false = if_else(DESTPLACE1 == "Accommodation" ,true = "home", 
                                                false = if_else(DESTPLACE1 == "Workplace", true = "work", 
                                                                false = if_else(DESTPLACE1 == "Place of Education", true = "edu", 
                                                                                false = if_else(DESTPLACE1 == "Shops", true = "shop", 
                                                                                                false = "other")))))) %>% 
  mutate(MAINMODE2 = if_else(LINKMODE %in% c("Taxi", "Train", "Public Bus", "School Bus", "Tram") ,true = "pt", 
                             false = if_else(LINKMODE == "Bicycle", true = "bike", 
                                             false = if_else(LINKMODE == "Walking", true = "walk", 
                                                             false = if_else(LINKMODE %in% c("Vehicle Driver", "Vehicle Passenger"), true = "car", 
                                                                             false = "other")))))



# Reading VISTA persons + filtering those living in Melbourne Metro
persons <- read_csv("./data/vista/P_VISTA12_16_SA1_V1.csv")%>% 
  filter(HomeRegion_ASGS == "Melbourne GCCSA")   # Filtering to the study region


# Simplifying persons' main activity tags
persons <- persons %>% 
  filter(NUMSTOPS > 0 )%>% 
  mutate(NOCYCLED = if_else(is.na(NOCYCLED), true = "Yes", false = as.character(NOCYCLED)))%>% 
  mutate(MAINACT2 = if_else(MAINACT %in% c("Full-time Work", "Part-time Work", "Casual Work"), true = "WORKER", 
                            false = if_else(MAINACT %in% c("Primary School", "Secondary School"), true = "SCHOOL_STUDENT", 
                                            false = if_else(MAINACT == "Full-time TAFE/Uni", true = "TAFE/Uni_STUDENT", 
                                                            false = "NOTWROKER" )))) 

# Sampling persons
library(splitstackshape)
persons_w <- expandRows(persons, "CW_ADPERSWGT_SA3", drop = FALSE)

persons_sampled <- persons_w %>% sample_n(size = (sample_size*nrow(persons_w)))

# Adding coordinates to stops:
sa1 <- read_sf("./data/abs/SA1_2011_AUST.shp") %>% 
  mutate(HomeSA1=as.double(SA1_MAIN11)) %>% 
  st_transform(28355)

# Adding origins
trips_sf <- trips %>% 
  left_join(st_centroid(sa1), by=c("ORIGSA1"="HomeSA1")) %>% 
  st_as_sf() %>% 
  cbind(st_coordinates(.)) %>% 
  rename(origX=X,origY=Y) %>%
  st_drop_geometry()

trips_sf <- trips_sf %>% 
  left_join(st_centroid(sa1), by=c("DESTSA1"="HomeSA1")) %>% 
  st_as_sf() %>% 
  cbind(st_coordinates(.)) %>% 
  rename(destX=X,destY=Y) %>%
  st_drop_geometry()

# removing trips that are having NA as x and y:
trips_sf <- trips_sf %>% 
  filter(!is.na(origX) & !is.na(origY) & !is.na(destX) & !is.na(destY))

# Starting to generate MATSim pop

xml_dir  <- "./"
xml_file  <- paste0(xml_dir,"pop",sample_size*100,"pct.xml")
ifelse(!dir.exists(xml_dir), dir.create(xml_dir), FALSE)
open(file(xml_file), "wt")

cat("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE population SYSTEM \"http://www.matsim.org/files/dtd/population_v6.dtd\">\n
<population>\n",file=xml_file,append=FALSE)

echo(paste0('generating MATSim cyclists (n = ', length(nrow(persons_sampled)),') with trips\n'))
#row_id <- 1
for (row_id in 1:nrow(persons_sampled)) {
  
  this_person <- persons_sampled[row_id,]
  this_trips <- trips_sf %>% filter(PERSID == as.character(this_person$PERSID))
  
  if(nrow(this_trips) == 0){
    cat("x")
  }else{
    df<-generateVISTAActsAndLeg(this_trips)
    if(is.null(df)) return(NULL)
    acts<-df[[1]]
    legs<-df[[2]]
    
    plan <-newXMLNode("person", attrs=c(id=row_id))
    
    plan <- addMATSimAttribsXML(this_person, plan)
    plan <- addMATSimActsAndLegsXML(plan, acts, legs)
    
    cat(saveXML(plan),
        file=xml_file,append=TRUE)
    cat("\n",file=xml_file,append=TRUE)
    
    if(row_id %%10 == 0) printProgress(row_id, nrow(persons_sampled), 'person')
  }
}

cat("</population>\n",file=xml_file,append=TRUE)

cat('\n')
echo(paste0('finished generating ',as.character(nrow(persons_sampled)),' persons\n'))
close(file(xml_file))

