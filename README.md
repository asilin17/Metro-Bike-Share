# Metro Bike Share Program in SF and LA: Impact Analysis

## Author: Alexey Silin

### Overview

#### Bike sharing programs have become popular in big cities over the last decade.In the most common arrangement, customers can rent a bike from an automated ”dock” and return it later to any other dock in the city. The charge the customer is based on how long they used the bike. The largest bike sharing program in the United States is in New York City, but bike shares have also recently formed in Los Angeles and the San Francisco Bay Area. The bike sharing programs in many cities publish anonymized data about trips and stations.

#### In this project I analyzed the data from Metro Bike Share Program. (See https://bikeshare.metro.net/about/data/)

#### The goal of the project was to gauge and report on user utilization of the program to bette serve costomer needs and for future strategic planing and expansion.  

### Results for Downtown Los Angeles
#### Compared to San Francisco, downtown LA doesn’t demonstrate such a heavy use of the program. There are slightly less stations located in the area, 65 (compared to 74 in SF.) A few of them serviced as many as 5,000 trips since the beginning of operations. The majority of stations serviced 3,000 - 5,000 trips. We also need to take into account the fact that Downtown LA is a much denser populated area, and receives a lot more pedestrian traffic on any given day than SF. Perhaps, also the traffic conditions on the road might not be as safe for cyclist. On the other hand, one would think that a lot of people might actually take advantage of a bicycle to navigate downtown LA and avoid traffic. 

#### The Los Angeles trips data also required some additional pre-processing to derive accurate and meaningful conclusions. 
#### 1) According to the official website: https://bikeshare.metro.net/about/data/
#### "Trips below 1 minute are removed." However, they were still present in the original dataset, and needed to be removed mannually
#### 2) "Staff servicing and test trips are removed."
#### However, there are 336 entries with the passholder type = Staff Annual. Some/all of them can potentially be staff servicing and test trips, which were not intended in the dataset. I decided to remove that data, in order to avoid ambiguity in findings. Since there are hundreds of thousands of customer trips recorded, omiting less than 0.3 percent of it seem justifiable.  
#### 3) Some stations have missing start_station_id = \\N Coordinates for those stations are missing, however trips are registered. In addition, the virtual station with station_id = 3000 doesn't have coordinates assigned to it. Based on description from the data source, those cases merely indicate the assignment a bycicle to a physical doc through the system. Since, there is no way to plot this data on the map, or gauge the trip direction (in case, if a trip physically happened,) those records were omited in tha analysis, as well. 
#### 4) There is a station in DTLA for which no trips are recorded. Upon further investigation, the station with ID 4220 has been opened recently 9/28/2017, and the trip dates are recorded up until 9/30/2017.
#### 5) There are stations with the same ID, but slightly different spelling of their names. Those cases have been consolidated, to show only the stations with unique id's. Note: it does not affect the total trip count made from those stations.
#### 6) Lastly, unlike with the SF staion data, in LA a single station sometimes has more than one set of coordinates. Ex.: Station 3005 (there are many others) has three different sets of  coordinates, but since all three values are minutely close geographically, only one of them - the first occuring coordinate - is selected. Note: selecting any other set of coordinates for a station with multiple sets does not visually change the representation of that station on the map. The reason for that might be that the station is near a public transportation hub and has docks on either side of a large street, or different ends of the same block. 

#### You can view the map of Downtown LA stations following the link below. Note: that the size of the dot on the map indicates the number of trips made from each station. It makes it easier to estimate the demand for services at any given location. 
#### https://github.com/asilin17/Metro-Bike-Share/blob/master/Mapped%20Stations/DTLA_Stations.pdf

### Results for Downtown San Francisco

#### Overall, the Bike Share program seem to be in high demand. Majority of stations account for more than 20,000 trips in just over a year of operation, with a few stations tripling that amount. Comparing this results with Downtown LA, we can see that bike share program is much more popular here: there are more stations, and more trips made of each on average. Plus, we need to take into account that Downtown SF is less densely populated than Downtown are of LA.  
#### After plotting stations on the map, we can see that the stations with most trips are located at the local commute hubs, such as Caltrain stations, Ferry building, BART stations in downtown, and local tourist attraction spots like Pier 39. 

#### You can view the map of Downtown SF stations following the link below. Note: as in case with Downtown LA data. The larger the dot, the busier the station. Hence, there is a higher demand for bike share services at that location.
#### https://github.com/asilin17/Metro-Bike-Share/blob/master/Mapped%20Stations/SF_Stations.pdf
