#!/usr/bin/env perl

# fast and ugly data reader and reporter
use LWP::UserAgent;
use DateTime;
use strict;
use IO::Socket;

my $data = {};

my $sensor_file = '/home/pi/serial_logs/current.wind';
my $tries_left = 2; # 2 tries only

SENSOR: while ($tries_left)
{
    $tries_left--;
    my $dht_file = '/home/pi/pi-weather-station/experimental/dht.last';

	my @dht22_out = `sudo ~/Adafruit-Raspberry-Pi-Python-Code/Adafruit_DHT_Driver/Adafruit_DHT 22 4`;
	my @bmp100_out = `sudo ~/Adafruit-Raspberry-Pi-Python-Code/Adafruit_BMP085/Adafruit_BMP085_example.py`;
    my $cached = 0;

	if (!$dht22_out[2])
	{
	    my $newer_than = time() - 300;		
	    warn "DHT sensor failed to return a value";
	    if ($tries_left)
	    {
	        sleep 5;
	        next(SENSOR);
	    }
	    else
	    {
		# check for last % (only keep for 5 min then ditch it)
		if (-f $dht_file)
		{
		    #how old?
		    my @stats = stat($dht_file);
		    if ($stats[9] > $newer_than) #last update time
		    {
			warn "DHT file seems ok: aged $stats[9]";
			$dht22_out[2] = `cat $dht_file`;
			$dht22_out[2] =~ s/[\r\n]//g;
			$cached = 1;
		    }
		    else
		    {
			warn "DHT cache too old ($stats[9] vs $newer_than) ";
			next(SENSOR);
		    }
                }
		else
		{
		    warn "No DHT file, done";
		    next(SENSOR); 
		}
            }
	}

	if (!$cached)
	{
	    warn "SAVE $dht22_out[2]";
	    open(DHT,"> $dht_file");
	    print DHT $dht22_out[2];
	    close DHT;
	}

	my @dht_split = split(/\s+/,$dht22_out[2]);
	my $dht_temp = $dht_split[2];
	my $dht_hum = $dht_split[6];

    if ($dht_hum > 99)
    {
        $dht_hum = 99;
    }
         
	print "DHT SENSOR: $dht_temp C / $dht_hum %\n";

	my ($b1,$bmp_temp,$r1) = split(/\s+/,$bmp100_out[0],3);
	my ($b2,$bmp_hpa,$r2) = split(/\s+/,$bmp100_out[1],3);
	my ($b3,$bmp_alt,$r3) = split(/\s+/,$bmp100_out[2],3);

	print "BMP SENSOR: $bmp_temp C / Station Pressure $bmp_hpa \n";

	my $ua = LWP::UserAgent->new();

=pod

	Sample uri

OB

CW0003>APRS,TCPIP*:/241505z4220.45N/07128.59W_032/005g008t054r001p078P048h50b10245e1w

=cut

	my $dt = DateTime->now;

	my $temp_f = (($bmp_temp * 9)/5)+32;
	# my $slp =  $bmp_hpa ** ((250)/(29.3 * $bmp_temp)); # sea level conversion

	my $slp = (($bmp_hpa - .3) * (1+ (( ((1013.25 ** .190284)*.0065)/288 ) * ( 250/ (($bmp_hpa-.3)**.190284) ))) ** (1/.190284)); # * 0.02952998751;

        my $sensorz = `cat $sensor_file`;
        $sensorz =~ s/[\r\n]//g;
        my ($dir_deg,$ws_mph,$gusts,$cur_precip_rate) = split(/:/,$sensorz);
	# apparently i cant report precip rate as in/hr, well "rainin" looks like a rate... we'll try it
	# i can do day to now total
	my $ldt = DateTime->now;
	$ldt->set_time_zone('America/New_York');
	my $rain_today_in = '0';
	
	my $rain_file = '/home/pi/serial_logs/' . $ldt->ymd . '/daily_rain_ticks.log';
 	if (-f $rain_file)	
	{
	   my $ticks = 0;
	    my @lines_of_rain = `cat $rain_file`;
	    foreach my $line (@lines_of_rain)
	    {
		$line =~ s/[\r\n]//g;
		my ($dt_str,$li_ticks) = split(/\|/,$line);
		$ticks+=$li_ticks;
	    }
	    $rain_today_in = $ticks * 0.011;
        }

	$bmp_hpa ** ((250)/(29.3 * $bmp_temp)); # sea level conversion
	my $dptf = $temp_f - ((9/25) * (100-$dht_hum)); # dewpoint F
    my $station = 'EW5253';
    my $location = '3914.88N/08440.68W';
    my $data = $station . '>APRS,TCPIP*:@' . sprintf("%02d",$dt->day) . sprintf("%02d",$dt->hour) . 
               sprintf("%02d",$dt->minute) . 'z' . $location . 
               '_' . sprintf("%03d",$dir_deg) . 
               '/' . sprintf("%03d",$ws_mph) . 
               'g' . sprintf("%03d",$gusts) . 
               't' . sprintf("%03d",$temp_f) . 
# last hour               'r' . sprintf("%03s",$ws_mph) . 
# last 24              'p' . sprintf("%03s",$ws_mph) . 
               'P' . sprintf("%03d",$rain_today_in * .01) . 
               'h' . sprintf("%02d",$dht_hum) . 
               'b' . sprintf("%05d",$slp * 10) . 
               'pi-weather-station-perl';

	print $data . "\n";

    my $s = IO::Socket::INET->new( PeerAddr => 'cwop.aprs.net',
                               PeerPort => 14580,
                               Proto => 'tcp', );
    if ($s)
    {
           print $s 'user ' . $station . ' pass -1 vers linux-1wire 1.00' . "\r\n";
           sleep 3;
           print $s $data . "\r\n";
           sleep 3;
           close ($s);
    }
    last(SENSOR);
}


