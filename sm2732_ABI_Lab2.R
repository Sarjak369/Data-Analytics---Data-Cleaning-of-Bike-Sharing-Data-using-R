# Name - Sarjal Atul Maniar
# Email - sm2732@scarletmail.rutgers.edu


str(Ch2_raw_bikeshare_data) # this gives the basic summary of the data

# bikeraw = copy(Ch2_raw_bikeshare_data)
# Important note : As Ch2_raw_bikeshare_data is a Data Frame, we can copy and create new data frame
# without using the copy command like this -> bikeraw = Ch2_raw_bikeshare_data. 
# But in the case of Data Table, if we try to directly assign the data to another variable then
# it will be the same data with different names.. i.e it will be pointing to the same memory location.

library(data.table)

setDT(Ch2_raw_bikeshare_data)

bikeraw <- copy(Ch2_raw_bikeshare_data) # As we have used copy command, so clearly bikeraw will be a separate table.

head(bikeraw)
str(bikeraw)

is.na(bikeraw) # FALSE means -> No NULL value and TRUE means ->  NULL value

# We can get a unique count of all the True and False using the table() function.

table(is.na(bikeraw)) 

# Function table() Example

c1=c('a','b','c')
c2=c('b','a','b')
c3=c('d','c','a')
dt=data.table(c1,c2,c3)
dt

# The table() function can count how many unique values there are in a column.

table(dt$c1)  
table(dt$c2)
table(dt$c3)

# But what if we have a data.table with many columns, how do we focus on which columns have NA’s?
# Answer is Stringr Package

library(stringr)

# Stringr Package (str detect)

# The str detect() function is a function from the stringr library. 
# It allows you to search for any particular string within the data.table. 
# Using the dt table example:

str_detect(dt,'d')

# Now lets run it on the data.table bikeraw:

str_detect(bikeraw, 'NA')
# So all of our original 554 NA that we found are all in the last (sources) column.
bikeraw[is.na(sources),NROW(sources)]  # df[Row Section,Column Section]

str(bikeraw)

# We see that the column humidity has numbers as values, but the column is of type ”chr” 
# which is strings (alphanumeric). We want to investigate why this is the case. 
# We will use function grep() that allows us to use ”regular expressions”. 
# Regular expressions are a way to find certain patterns in strings.

bikeraw[grep('[a-z A-Z]',humidity)]

bikeraw[grep('[a-z A-Z]',humidity), humidity] # row, column

bikeraw[grep('[a-z A-Z]',humidity),humidity:='61']
# In data.tables, for overwriting an existing value in a column, we use ':='

# Notice we put it in quotes. It’s because the data type of the column is still ”chr”.
# We have to convert the datatype for the column.

# Converting Data Type- Humidity
# R has a series of functions called as.{type}() that allows you to change data from one type to another.

bikeraw[,humidity:= as.numeric(humidity)]
class(bikeraw$humidity) # numeric

str(bikeraw)

# Factors

data = c(1,2,2,3,1,2,3,3,1,2,3,3,1)
fdata = factor(data)
fdata

rdata = factor(data,labels=c("I","II","III")) # labeling the levels
rdata

# Factors - Holiday/Workingday

unique(bikeraw$holiday)
bikeraw[,holiday:=factor(holiday, levels = c(0,1),labels = c('not holiday','holiday'))]
bikeraw$holiday
unique(bikeraw$holiday)
table(bikeraw$holiday)
   
unique(bikeraw$workingday)
bikeraw[,workingday:=factor(workingday , levels = c(0,1), labels = c('not working','working'))]
bikeraw$workingday
unique(bikeraw$workingday)
table(bikeraw$workingday)

# Ordered Factors - Season/Weather

unique(bikeraw$season)
bikeraw[,season:=factor(season, levels = c(1,2,3,4),labels = c('spring','summer','fall','winter'), ordered = T)]
unique(bikeraw$season)

unique(bikeraw$weather)
bikeraw[,weather:=factor(weather, levels = c(1,2,3,4), labels = c('clr_part_cloud','mist_cloudy','lt_rain_snow','hvy_rain_snow'),ordered = T)]
unique(bikeraw$weather)

# Date and Time Conversions
# We will convert the datetime column from "characters" to actual "date" data type because
# if it's in char format, then it is not ready for data analysis. 


bikeraw[,.(datetime)] # getting all the rows of datetime column -> df[row, column]
class(bikeraw$datetime)

# The as.Date() function creates dates
# Example working
# Let us create a vector of actual dates

dt=c(as.Date('2018-01-01'),as.Date('2018-03-03'),as.Date('2018-05-01'),as.Date('2018-05-31'))
dt
# The format of dates in R is yyyy-mm-dd

price=c(4,8,10,12)
sampdt = data.table(dt,price)
sampdt
str(sampdt)

bikeraw[,datetime:=as.Date(datetime , '%m/%d/%Y %H:%M')] 
# we need to explicitly tell that the dates in our datetime column is in mm-dd-yyyy format
# Because by default date format in R is yyyy-mm-dd, if while matching this it will give an error
# '%m/%d/%Y %H:%M' -> explicitly specifying the actual format

str(bikeraw) 
# Now we can see that it shows the default date format after it matches with our
# explicitly provided date format which was used for datetime column
# Also notice one more thing that now if you see the datetime column, time is not printed.
# Only the dates are printed. This is done for the sake of memory efficiency because 
# a lot of time you don't need the time. But suppose you want the time then we use strptime function.

# Date and Time Conversions - With Time

# The strptime() function creates dates with times, not recommended because of 
# large data storage.

unique(bikeraw$datetime)
bikeraw[,period:=strptime(datetime , '%m/%d/%Y %H:%M')]
unique(bikeraw$period)
bikeraw[,datetime:=as.Date(datetime , '%m/%d/%Y %H:%M')] 
 
str(bikeraw)
# So now, we have no more column with "Character" data type except one i.e the sources column

# Adapting String Variables To Standards
# If you check the sources column, it is still a chr datatype, infact it is the 
# only chr column datatype left in our table. The problem is that R CANNOT group 
# character items to summarize them in analysis. This implies that maybe sources 
# should be categorical data too, but before we convert we have to ask ourselves 
# if the variation in data is helpful. 
# To be specific:
# -> How many unique kids of advertising sources are in sources?
# -> How many categories would you like to have in your analysis dataset?

unique(bikeraw$sources)
# Observations:
# 2 Twitter values?
# Multiple ad campaigns
# The NA

# Let's fix these obvious mistakes..

bikeraw[, sources:=tolower(sources)]
unique(bikeraw$sources) # now we are left with 12 values from 14 values..

# now, to remove the extra white space, we use trimws function (it trims white space before and after)
bikeraw[,sources:=trimws(sources)]
unique(bikeraw$sources)

# for NA value, we are just going to knock out by writing unknown
bikeraw[is.na(sources), sources:=('unknown')]
unique(bikeraw$sources)

# # 11 values left, is that better?
# Answer -> Miller's Law
# George Miller, Princeton Professor and psychologist, stated that the 
# number of objects an average person can hold in working memory is about seven, 
# also known as The Magical Number Seven, Plus or Minus Two.

# After discussing it with advertisers, you might come to the realization 
# that its not that important to know which search engine the user used, 
# just that they came from the web (matters if you are paying for google AdWords). 
# Therefore we want to replace anything that has a website to just ”web”.


bikeraw[grep('www.[a-z]*.[a-z]*',sources),sources:='web']
unique(bikeraw$sources)

# We are now left with 7 and we are ready to rock. And, Miller's Law is also achieved.

# Now, going one step further, we can convert the sources column into a categorical column
# obviously it will be of type NOMINAL

bikeraw[,sources:=factor(sources, levels = c('ad campaign','web','twitter','facebook page', 'unknown', 'direct', 'blog'), labels = c(1,2,3,4,5,6,7))]
unique(bikeraw$sources)

str(bikeraw)

















