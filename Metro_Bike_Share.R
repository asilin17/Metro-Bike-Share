#######################################################################
# METRO BIKE SHARE PROGRAM IMPACT ANALYSIS
# AUTHIR: Alexey Silin
#######################################################################

#Data for this project can be downloaded here: https://bikeshare.metro.net/about/data/


###############################################################################
# Installin pacakges. Note: "devtools" needed for proper functioning of "ggmap"
###############################################################################
library(lubridate)
library(readr)
library(maps)
library(ggplot2)
library(ggrepel)
library(ggmap)
install.packages("devtools")
devtools::install_github("dkahle/ggmap")
library(devtools)
library(dplyr)
library(tidyr)

##################################################################
#extracting files from zip folder
##################################################################
filename <- "bikes.zip"
unzip(filename, files = NULL, list = FALSE, overwrite = TRUE, junkpaths = FALSE, exdir =
        "./bikes", unzip = "internal", setTimes = FALSE)

##################################################################
# SF DATA IMPORT
##################################################################
#function for san francisco trips data
make_sf_trips_rds = function(
  path = "sf_bikeshare_trips.csv",
  output = "sf_bikeshare_trips.rds"
) {

  df = read_csv(path)
  
  #changing variable types
  df$trip_id <- factor(df$trip_id)
  df$start_station_id <- factor(df$start_station_id)
  df$end_station_id <- factor(df$end_station_id)
  df$bike_number <- factor(df$bike_number)
  
  #change to show hrs/min/sec
  df$duration_sec <- seconds_to_period(df$duration_sec)  #change to show hrs/min/sec
  names(df)[names(df) == "duration_sec"] <- "duration"
  
  #converting dates into POSIX format
  df$start_date <- as.POSIXct(df$start_date)
  df$end_date <- as.POSIXct(df$end_date)
  
  saveRDS(df, output)
  
  df
}

make_sf_trips_rds()

#function for san francisco stations data
make_sf_stations_rds = function (
  path = "sf_bike_share_stations.csv",
  output = "sf_bike_stations.rds"
  ) {
  
  df = read_csv(path)
  
  #changing variable types
  df$station_id <- factor(df$station_id)
  df$landmark <- factor(df$landmark)
  df$installation_date <- as.POSIXct(as.character(df$installation_date))
 
  saveRDS(df, output)

  df

}
make_sf_stations_rds()

#################################################################################################### 
# IMPORTING LOS ANGELES TRIP DATA 
####################################################################################################

#function for Los Angeles trips data
make_la_trips_rds = function(
  path = c("2016_q3_la_metro_trips.csv",
           "2016_q4_la_metro_trips.csv", 
           "2017_q1_la_metro_trips.csv",
           "2017_q2_la_metro_trips.csv",
           "2017_q3_la_metro_trips.csv"),
  output = "la_bikeshare_trips.rds"
) {
  
  #creates the list of dataframes
  #used some code from PIAZZA @421
  data <- lapply(path, read.csv) #used code from PIAZZA @421
  
  #converts the names of colums (start/end_station into start/end_station_id)
  #so that they match the rest of the data
  colnames(data[[4]]) <- colnames(data[[1]]) 
  colnames(data[[5]]) <- colnames(data[[1]]) 
  
  #combines all 5 dataframes into one
  df <- do.call(rbind, data)    #used some code from PIAZZA @421
  
  #changing variable types
  df$trip_id <- factor(df$trip_id)
  df$start_station_id <- factor(df$start_station_id)
  df$end_station_id <- factor(df$end_station_id)
  df$bike_id <- factor(df$bike_id)
  df$trip_route_category <- factor(df$trip_route_category)
  df$passholder_type <- factor(df$passholder_type)
  
  #change to show hrs/min/sec
  df$duration <- seconds_to_period(df$duration)  #change to show hrs/min/sec
  df$plan_duration <- seconds_to_period(df$plan_duration)
  
  #converting dates into POSIX format
  df$start_time <- as.POSIXct(df$start_time, format = "%m/%d/%Y %H:%M") 
  df$end_time <- as.POSIXct(df$end_time, format = "%m/%d/%Y %H:%M")
  
  saveRDS(df, output)
  df
}
make_la_trips_rds()

#functioin for LA stations data
make_la_stations_rds = function(
  path = "metro-bike-share-stations-2017-10-20.csv",
  output = "la_bikeshare_stations.rds"
) {
  
  df = tbl_df(read_csv(path)) 
  
  names(df) = tolower(names(df)) #week5examples
  
  #converting dates into POSIX format
  df <- df[-1,] #removing Virtual Station, since no trips made from there
  df$go_live_date <- as.POSIXct(df$go_live_date, format = "%m/%d/%Y")
  
  #changing  other variable types
  df$station_id <- factor(df$station_id)
  df$station_name <- factor(df$station_name)
  df$region <- factor(df$region)
  df$status <- factor(df$status)
  
  saveRDS(df, output)
  
  df
}

make_la_stations_rds()

################################################################################
# MAPPING SAN FRANCISCO STATIONS
################################################################################

#converting data into table-dataframe format for easy data processing with
#"dplyr" and "tidyr" pacakeges, alternatively "tidyverse" can be used 
#to achieve the same effects
sf_data <- tbl_df(readRDS("sf_bikeshare_trips.rds"))
sf_stations <- tbl_df(readRDS("sf_bike_stations.rds"))

#counting number of trips started from a station and saving result into a new dataframe
sf_trip_counts <- sf_data %>%
  select(start_station_name, start_station_id) %>%
  group_by(start_station_id) %>%
  summarize(num_trips = n()) %>%
  arrange(desc(num_trips)) %>%
  print

#subsetting the stations dataframe to remove duplicates (only showing unique stations)
sf_stations <- sf_stations[!duplicated(sf_stations$station_id),]

#merging two dataframes to have station coordinates for mapping (lat, lon) and
#trip counts for each station
sf_stations <- merge(sf_trip_counts, sf_stations, by.x = "start_station_id", by.y = "station_id")
names(sf_stations)[names(sf_stations) == "start_station_id"] <- "station_id"

#Plotting the map and statations together
sf_map <- get_map( c(lon = -122.40297, lat = 37.78772), zoom = 14, maptype = "roadmap")
ggmap(sf_map) +  
  geom_point(data = sf_stations, 
             aes(x = longitude, y = latitude, size = num_trips), 
             alpha =  .5, col = "red") +
  labs(size = "Number of Trips") +
  ggtitle("San Francisco Bike Share Stations") +
  geom_label_repel(data = sf_stations,  #https://cran.r-project.org/web/packages/ggrepel/ggrepel.pdf
            aes(x = longitude, y = latitude, label = name), 
            box.padding = .1,
            label.padding = .1,
            label.size = .2,
            size = 2.3)
         


################################################################################
# MAPPING LOS ANGELES STATIONS
################################################################################

#converting data into table-dataframe format for easy data processing with
#"dplyr" and "tidyr" pacakeges, alternatively "tidyverse" can be used 
#to achieve the same effects
la_stations <- tbl_df(readRDS("la_bikeshare_stations.rds"))
la_trips <- tbl_df(readRDS("la_bikeshare_trips.rds"))

# DATA PREPROCESSING:
# Unlike with San Francisco, the Los Angeless data needs to be preprocessed before plotting. There are six resons for that:

# 1) According to the data source, https://bikeshare.metro.net/about/data/:
# "Trips below 1 minute are removed." However, they are still present in the original dataset, and need to 
# removed. 
la_trips <- la_trips[la_trips$duration > "1M",]  #Trips below 1 minute are removed.

# 2)"Staff servicing and test trips are removed."
# However, there are 336 entries with the passholder type = Staff Annual. Some/all of them
# are potentially staff servicing and test trips, which were also not intended in the dataset. 
# They will be omited in this portion of analysis. 
la_trips <- la_trips[la_trips$passholder_type != "Staff Annual",] #Staff servicing and test trips are removed.

# 3)Some stations have missing start_station_id = \\N, coordinates for those stations are
# missing, however trips are registered. In addition, virtual station with station_id = 3000
# doesn't have coordinates assigned to it. 
# Upon investigating trips for virtual station: some have duration of just a few seconds. It
# is very unlikely in this case that an actual trip has taken place. Most likely, a trip
# with start_station_id = 3000, means an assignment of a bycicle to a physical doc through
# the system. Since there is no way to plot this data on the map (coordinates are missing in case of \\N, 
# and non-existent in case of the 'Virtual Station') it won't be used in this step of the analysis. 
# Plus there is a good chance that at least some of it is 'Staff servicing and test trips'
# They are said to be removed (see link above for reference), but could actually have 
# been included (by mistake, at it is the case with the trips that last < 1M, which were not 
# actually removed from the data set.)
# Subsetting for stations located in Downtown LA and for trips from those 
# stations effectively takes care of that.
dtla_stations <- subset(la_stations, region == "DTLA") 
droplevels.factor(dtla_stations$station_id)

#selecting trips that started in Downtown LA
dtla_trips <-subset(la_trips, start_station_id %in% droplevels.factor(dtla_stations$station_id))
droplevels.factor(dtla_trips$start_station_id)

# 4) Lastly, there is a station in DTLA for which no trips are recorded.
# The station with ID 4220 has been opened recently 9/28/2017, 
# and trip dates are recorded up until 9/30/2017.
dtla_stations$station_id %in% intersect(dtla_stations$station_id, dtla_trip_counts$start_station_id)
la_trips[la_trips$start_station_id == "4220",] #returns 0x14 table i.e. no trips from this station
la_stations[la_stations$station_id == "4220",] 

# Perhaps, no  trips have been actually made from that station within the 
# first two days of going live (or the info hasn't been properly recorded in the system)
# I removed that station from the list of stations before counting the trips.
dtla_stations <- subset(dtla_stations, station_id != "4220") 

# 5) There are stations with the same ID, but slightly different spelling of
# their names. Those cases also have been consolidated, to show only the
# stations with unique id's. Note: it does not affect the total trip count
# made from those stations.
dtla_trips[!duplicated(dtla_trips$start_station_id),] 

# 6) Unlike with the SF staion data, in LA a single station sometimes has more than one set of coordinates. 
# Ex.: Station 3005 (there are many others) has three different sets of  coordinates, but since all three 
# values are very close, only one of them - the first occuring coordinate - is selected. 
# Note: selecting any other set of coordinates for a station that has multiple sets does not visually 
# change the locatio of that station on the map, since, as in case with the staion ID 3005, 
# those coordinates are very close.
dtla_station_coord <- dtla_trips[!duplicated(dtla_trips$start_station_id),] %>%
  select(start_station_id,start_lat, start_lon) %>%
  print

# Now, after all the necessary cleaing is done, we can finally estimate the correct amount of the trips 
# made from each station in Downtown LA.

#getting trip counts per station
dtla_trip_counts <- dtla_trips %>%
  select(start_station_id, start_lat, start_lon) %>%
  group_by(start_station_id) %>%
  summarize(num_trips = n()) %>%
  print

#merging dtla stations data to include id, name, and coordinates for plotting on the map
dtla_stations_new <- tbl_df(merge(dtla_stations, dtla_station_coord, 
                                  by.x = "station_id", 
                                  by.y = "start_station_id"))
dtla_stations_new <- tbl_df(merge(dtla_stations_new, dtla_trip_counts,
                                  by.x = "station_id", 
                                  by.y = "start_station_id"))

#renaming columns into more appropriate names
colnames(dtla_stations_new)[c(2,6,7)] <- c("name", "latitude", "longitude")

# PLOTTING RESULTS ON DOWNTOWN LA MAP
# google searched 'coordinates of downtown la': 34.0407° N, 118.2468° W

#Plotting the map and statations together
la_map <- get_map( c(lon = -118.2468, lat = 34.05), zoom = 14, maptype = "roadmap")
ggmap(la_map) + 
  geom_point(data = dtla_stations_new, 
             aes(x = longitude, y = latitude, size = num_trips),
             alpha =  .5, col = "red") +
  labs(size = "Number of Trips") +
  ggtitle("Downtown LA Bike Share Stations") +
  geom_label_repel(data = dtla_stations_new,  
                   
            aes(x = longitude, y = latitude, label = name),
            box.padding = .1,
            label.padding = .1,
            label.size = .2,
            size = 2.3)

