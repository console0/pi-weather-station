#!/usr/bin/env perl

# fast and ugly data reader and reporter
use LWP::UserAgent;
use DateTime;
use strict;
use URL::Encode qw(url_encode);

my $data = {};
my $pass = url_encode(shift) || exit;

=pod

pi@raspberrypi ~/pi-weather-station/experimental/fast_hack $ sudo ~/Adafruit-Raspberry-Pi-Python-Code/Adafruit_DHT_Driver/Adafruit_DHT 22 4
Using pin #4
Data (40): 0x3 0x8f 0x0 0xac 0x3e
Temp =  17.2 *C, Hum = 91.1 %
pi@raspberrypi ~/pi-weather-station/experimental/fast_hack $ vi hack.pl
pi@raspberrypi ~/pi-weather-station/experimental/fast_hack $ sudo ~/Adafruit-Raspberry-Pi-Python-Code/Adafruit_BMP085/Adafruit_BMP085_example.py
Temperature: 17.60 C
Pressure:    977.81 hPa
Altitude:    299.25

=cut

my $tries_left = 2; # 2 tries only

SENSOR: while ($tries_left)
{
    $tries_left--;

	my @dht22_out = `sudo ~/Adafruit-Raspberry-Pi-Python-Code/Adafruit_DHT_Driver/Adafruit_DHT 22 4`;
	my @bmp100_out = `sudo ~/Adafruit-Raspberry-Pi-Python-Code/Adafruit_BMP085/Adafruit_BMP085_example.py`;

	if (!$dht22_out[2])
	{
	    warn "DHT sensor failed to return a value";
	    sleep 5;
	    next(SENSOR);
	}

	my @dht_split = split(/\s+/,$dht22_out[2]);
	my $dht_temp = $dht_split[2];
	my $dht_hum = $dht_split[6];

	print "DHT SENSOR: $dht_temp C / $dht_hum %\n";

	my ($b1,$bmp_temp,$r1) = split(/\s+/,$bmp100_out[0],3);
	my ($b2,$bmp_hpa,$r2) = split(/\s+/,$bmp100_out[1],3);
	my ($b3,$bmp_alt,$r3) = split(/\s+/,$bmp100_out[2],3);

	print "BMP SENSOR: $bmp_temp C / Station Pressure $bmp_hpa \n";

	my $ua = LWP::UserAgent->new();

=pod

	Sample uri

	http://rtupdate.wunderground.com/weatherstation/updateweatherstation.php?ID=KCASANFR5&PASSWORD=XXXXXX&dateutc=2000-01-01+10%3A32%3A35&winddir=230&windspeedmph=12&windgustmph=12&tempf=70&rainin=0&baromin=29.1&dewptf=68.2&humidity=90&weather=&clouds=&softwaretype=vws%20versionxx&action=updateraw&realtime=1&rtfreq=2.5

=cut

	my $dt = DateTime->now;
	my $date = url_encode($dt->ymd . ' ' . $dt->hms);

	my $temp_f = (($bmp_temp * 9)/5)+32;
	# my $slp =  $bmp_hpa ** ((250)/(29.3 * $bmp_temp)); # sea level conversion

	my $slp = (($bmp_hpa - .3) * (1+ (( ((1013.25 ** .190284)*.0065)/288 ) * ( 250/ (($bmp_hpa-.3)**.190284) ))) ** (1/.190284)) * 0.02952998751;


	$bmp_hpa ** ((250)/(29.3 * $bmp_temp)); # sea level conversion
	my $dptf = $temp_f - ((9/25) * (100-$dht_hum)); # dewpoint F

	my $urlstr = "http://rtupdate.wunderground.com/weatherstation/updateweatherstation.php?ID=KOHCINCI77&PASSWORD=$pass&dateutc=$date&tempf=" . 
		      url_encode($temp_f) . "&baromin=" .  url_encode($slp) . "&dewpointf=" .  url_encode($dptf) . 
		     "&humdity=" .  url_encode($dht_hum) . "&softwaretype=" .  url_encode("pi-weather-station") . "&action=updateraw&realtime=1&rtfreq=60";
	print $urlstr . "\n";
	my $rs = $ua->get($urlstr);
	print $rs->content . "\n";

    last(SENSOR);
	#my $response = $ua->get("http://rtupdate.wunderground.com/weatherstation/updateweatherstation.php?ID=KOHCINCI77&password=$pass&dateutc=$date&tempf=$temp_f&baromin=$slp&dewpointf=$dptf&humdity=$dht_hum&softwaretype=pi-weather-station&action=updateraw&realtime=1&rtfreq=30");
}


