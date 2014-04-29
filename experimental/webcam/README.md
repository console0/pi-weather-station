Use the following crontab

# m h  dom mon dow   command
5,15,25,35,45,55 * * * * /home/pi/pi-weather-station/experimental/webcam/snap.sh
0,10,20,30,40,50 * * * * /home/pi/pi-weather-station/experimental/webcam/upload.pl 'yourpass'

FTP instructions from: http://wiki.wunderground.com/index.php/WunderCams_FTP
