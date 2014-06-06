# szelenka 2014-06-05
# Plot2 for Programming Assignment in exdata-003

# specify the source of the data, stop if not present
filename <- "./household_power_consumption.txt"
if (!file.exists(filename)) {
  warning(paste("Working Directory:",getwd()))
  stop("unable to locate file")
}

# load dependencies
library(sqldf)

# only load data from 1/2/2007 and 2/2/2007 
# handle '?' as NA

# read.table will load the entire file into memory, which is under 200MB
# then filtering the data to only dates we care about and converting to appropriate types
#data <- read.table(file=filename, sep=";", header=TRUE, na.string="?")
#data <- subset(data,data[,1]=="1/2/2007" | data[,1]=="2/2/2007")

# looping through each line 1-by-1 may work, but we'll be I/O bound by disk access
# accessing the file multiple times to save memory may not be the best idea
#len <- length(readLines(filename))
#for(i to len) {
#  tmp <- read.table(file=filename,sep=";", header=TRUE, na.string="?",skip=i,nrow=1)
#  if (tmp[1,1] != '1/2/2007' && tmp[1,1]!= '2/2/2007') {
#    next;
#  }
#  data <- rbind(data,tmp)
#}

# read.csv.sql is margionally quicker but it will convert the '?' values into '0.00' rather than NA
# a workaround is to load the entire data.frame first, then filter using sqldf
# however, this doesn't really give us any performance boost, since we're still loading the entire file into memory first
#data <- read.csv(file=filename,sep=";", header=TRUE, na.string="?")
#data <- read.csv.sql(data, sql="SELECT * FROM file WHERE Date = '1/2/2007' OR Date = '2/2/2007'")

# after maually inspecting the data, there doesn't appear to be any '?' values for the dates
# in question for this assignment, so one could just use sqldf..
data <- read.csv.sql(file=filename,sep=";", header=TRUE, sql="SELECT * FROM file WHERE Date = '1/2/2007' OR Date = '2/2/2007'")

# convert Date/Time into date/time object
data$datetime <- strptime(paste(data$Date,data$Time),format="%e/%m/%Y %X")

# specify window parameters
par(pin=c(5,5), cex=0.75, cex.main=0.9, cex.axis=0.75, cex.lab=0.75, bg="transparent", mfrow=c(1,1), mar=c(5,4.5,3,2))

# generate plot
plot(data$datetime,data$Global_active_power, type="l",ylab="Global Active Power (kilowatts)",xlab="")

# save to PNG file on disk
dev.copy(png,"./plot2.png",width=480,height=480,units="px",pointsize=10)
dev.off()