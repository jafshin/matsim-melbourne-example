generateVISTAActsAndLeg <- function(stps){
  #stps <- this_trips
  acts<-data.frame(id=NA, type=NA, sa1=NA, x=NA, y=NA, start_hhmmss=NA, end_hhmmss=NA)
  legs<-data.frame(origin_act_id=NA,mode=NA,dest_act_id=NA)
  
  for (j in 1:nrow(stps)) {
    acts[j,"id"] <- j
    acts[j,"type"] <- as.character(stps$ORIGPLACE1_2[j])
    acts[j,"sa1"] <- as.character(stps$ORIGSA1[j])
    acts[j,"x"] <- stps$origX[j]
    acts[j,"y"] <- stps$origY[j]
    acts[j,"start_hhmmss"] <- sprintf("%02d:%02d:00",as.integer(as.character(stps$STARTHOUR[j])), as.integer(as.character(stps$STARTIME[j]))%%60)
    acts[j,"end_hhmmss"] <- sprintf("%02d:%02d:00",as.integer(as.character(stps$ARRHOUR[j])), as.integer(as.character(stps$ARRTIME[j]))%%60 )
  }
  # the last stop:
  j <- j+1
  acts[j,"id"] <- j
  acts[j,"type"] <- as.character(stps$DESTPLACE1_2[j-1])
  acts[j,"sa1"] <- as.character(stps$DESTSA1[j-1])
  acts[j,"x"] <- stps$destX[j-1]
  acts[j,"y"] <- stps$destY[j-1]
  acts[j,"start_hhmmss"] <- sprintf("%02d:%02d:00",as.integer(as.character(stps$ARRHOUR[j-1])), as.integer(as.character(stps$ARRTIME[j-1]))%%60)
  acts[j,"end_hhmmss"] <- "23:59:59"
  # Legs
  for(j in 1:nrow(stps)){
    legs[j, "origin_act_id"] <- j
    legs[j, "mode"] <- as.character(stps$MAINMODE2[j])
    legs[j, "dest_act_id"] <- j+1
  }
  
  return(list(acts,legs))
}


