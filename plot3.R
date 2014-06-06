# szelenka 2014-06-05
# Plot3 for Programming Assignment in exdata-003

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

# writing the plot to screen then dev.copy will result in legend problems
# write directly to PNG to workaround this issue
png("./plot3.png",width=480,height=480,units="px",pointsize=10)

# specify window parameters
par(pin=c(5,5), cex=1, cex.main=1.5, cex.axis=1.25, cex.lab=1.25, bg="transparent", mfrow=c(1,1), mar=c(5,4.5,3,2))

# generate plot
plot(data$datetime,data$Sub_metering_1, type="n",ylab="Energy sub metering",xlab="")
lines(data$datetime,data$Sub_metering_1, lty=1, col="black")
lines(data$datetime,data$Sub_metering_2, lty=1, col="red")
lines(data$datetime,data$Sub_metering_3, lty=1, col="blue")
legend("topright", c("Sub_metering_1","Sub_metering_2","Sub_metering_3"), lty=1, col=c("black","red","blue"), border="black", cex=1.25)

# save to PNG file on disk
dev.off()