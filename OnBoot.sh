#!/bin/bash
######################
# Simple bash script for retrive date / Lat / Lon
# Date is set on localdevice and push to the Nextstar
# LAT/LON are also set to the nextstar
# 
# Write by loops34atgmail.com
#
######################

GPSDATA="/tmp/gpsdata.data"
NAME=gpsd
SERIAL="/dev/ttyUSB0"
NEXSTARDATA="/tmp/nexstar.log"
OUTPUTIMG="/tmp/shot4solver.jpg"
PLATESOLVE="/tmp/scaleplate.log"

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# check if socket exist
if [ -z "$GPSD_SOCKET" ] && [ -z "$DEVICES" ]; then
	GPSD_SOCKET=/var/run/gpsd.sock
fi
	# check/delete and create /tmp/gpsdata.data
	if [ -e $GPSDATA ]; then
  	   rm $GPSDATA 
  	   gpspipe -w -n 10 -o $GPSDATA 
	else
  	   gpspipe -w -n 10 -o $GPSDATA 
	fi
	
	# Get Lat/Lon from GPS		
	GPSLAT=`cat $GPSDATA | grep TPV | sed -r 's/.*"lat":([^",]*).*/\1/' | ta
il -1`
	echo Lat:$GPSLAT

	GPSLON=`cat $GPSDATA | grep TPV | sed -r 's/.*"lon":([^",]*).*/\1/' | ta
il -1`
	echo Lon:$GPSLON
#else
#	echo "GPS Not Installed - Connect a GPS Module"
#	exit 1
#fi

# check if nexstar is UP
if [ -f $SERIAL ]; then
  	nexstarctl info $SERIAL > $NEXSTARDATA
fi	
	GPSDATE=`cat $GPSDATA | grep TPV | sed -r 's/.*"time":"([^"]*)".*/\1/' |
 tail -1`
	echo GPS_date:$GPSDATE
	sudo date -s "$GPSDATE"
	nexstarctl settime $SERIAL
	nexstarctl setlocationdec $GPSLON $GPSLAT $SERIAL

#else
#	echo "Nexstar Module not connected"
#fi




# Prise de photo via la PiCam
#raspistill -ss 6000000 -awb off -awbg 1,1 -ISO 100 -t 60000 -o "$OUTPUTIMG"
#solve-field --scale-low 10 $OUTPUTIMG --overwrite > $PLATESOLVE 2>&1
#VALUE=`grep "Field center: (RA,Dec)" $PLATESOLVE | cut -c27- | sed -r 's/\) deg
\.//'`
#RA=`echo $VALUE | awk -F "," '{print $1}'`
#echo "RA=$RA"
#DEC=`echo $VALUE | awk -F "," '{print $2}'`
#echo "DEC=$DEC"
#nexstarctl syncdeg $RA $DEC $SERIAL
