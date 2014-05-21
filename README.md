pi-weather-station
==================

Making a PWS from a Pi

Things I've used from elsewhere to make this work so far:

https://github.com/adafruit/Adafruit-Raspberry-Pi-Python-Code

https://learn.adafruit.com/using-the-bmp085-with-raspberry-pi/overview

https://learn.adafruit.com/dht-humidity-sensing-on-raspberry-pi-with-gdocs-logging/software-install

I've hacked together a proto board from the above diagrams, I'll add the schematic soonish

Current implementation proto system reports as KOHCINCI77:

http://www.wunderground.com/personal-weather-station/dashboard?ID=KOHCINCI77#current

TODO
====

Hardware for anemometer, solar/uv sensors and rain guage.  

I'll need to re-do the board to get all of the new sensors added.  

I might go arduino as a usb or serial device for the solar/rain/anemometer.

Use XS to create a perl module to do the sensor access to remove the command line dependencies.

Make the reporting cam and rapid-fire code configurable

Chameleon5 builtin site for xml->xsl serving of data via http on-demand
