changeVISTACoordianteSystem <- function(old_acts, new_crs){
  
  new_acts <- st_as_sf(old_acts, coords = c("x", "y"), crs = 4326) %>% 
    st_transform(new_crs)
  
  new_acts[,c("x", "y")] <- do.call(rbind, st_geometry(new_acts)) %>% 
    as_tibble() %>%
    setNames(c("x","y")) 
  
  new_acts <- new_acts %>% st_set_geometry(NULL) %>% select("id", "type", "sa1", "x", "y", "start_hhmmss", "end_hhmmss")
  
  return(new_acts)
}