# Set up the serial port

use strict;
use IO::Socket::INET;
use LWP::UserAgent;
use URL::Encode qw(url_encode);
use DateTime;
use Device::SerialPort;
use List::Util qw(reduce);
use Redis::Client;
my $localdate = DateTime->now->set_time_zone('local')->truncate( to => 'day' );
my $client = Redis::Client->new( host => 'localhost', port => 6379 );
my $port = Device::SerialPort->new("/dev/tty.usbserial-AH02V8Z4");

# 19200, 81N on the USB ftdi driver
#$port->baudrate(19200); # you may change this value
$port->baudrate(9600); # you may change this value
$port->databits(8); # but not this and the two following
$port->parity("none");
$port->stopbits(1);

my $cwop = 0;
my $buf;
my $skip = 1;
my $iter = 0;
my $t15 = 0;
my $r15 = 0;
my $ua = LWP::UserAgent->new();

my @w_sensor_levels = qw( 380 393 414 456 508 551 615 680 746 801 833 878 913 940 967 990 );
my %sensor_to_direction = (
                             380 => 113,
                             393 => 68,
                             414 => 90,
                             456 => 158,
                             508 => 135,
                             551 => 203,
                             615 => 180,
                             680 => 23,
                             746 => 45,
                             801 => 248,
                             833 => 225,
                             878 => 338,
                             913 => 0,
                             940 => 293,
                             967 => 315,
                             990 => 270,
                        );

my @l60;
$l60[239] = 0;
my $first = 1;
my $reset_counter;
my $offset;

print         "  Temp  | Dewpt  | RH    | SLP   | Wind | MPH  | Rain \n";       

while (1)
{
  my ($count,$line) = $port->read(1);
  if ($count)
  {
    #warn $count. ",".$line . "\n";
    $buf .= $line;
    if ($buf =~ /\$$/)
    {
        if (!$skip)
        {
            $buf =~ s/\$$//g;
            my ($wind_direction,$wind_speed,$wind_gust,$wind_gust_direction,$humidity,$temp_f,$rain_in_1hour,$rain_in_24hour,$barom_hpa,$rain_dumps_sec,$wind_toggles_sec,@overflow) =
                split( /\,/, $buf);
                
            # print $buf . "\n";

            if (!$overflow[0])
            {
                my $today = DateTime->now->set_time_zone('local')->truncate( to => 'day' );
                $iter++;
                $temp_f =~ s/^t//g;
                $humidity =~ s/^h//g;
                $barom_hpa =~ s/^b//g;
                $rain_in_1hour =~ s/^p//g;
                $rain_in_24hour =~ s/^dp//g;
                $wind_direction =~ s/^wd//g;
                $wind_speed =~ s/^ws//g;
                $wind_gust =~ s/^wg//g;
                $wind_speed =~ s/nan/0/g;
                $wind_gust =~ s/nan/0/g;
                $t15+=$wind_toggles_sec;
                $r15+=$rain_dumps_sec;
                my $wind_deg;
                if ((length($temp_f) == 0) || (length($humidity) == 0) || (length($barom_hpa) == 0) || (length($wind_direction) == 0) || (length($wind_speed) == 0)
                    || (length($wind_gust) == 0))
                {
                    warn "missed read";
                    next;
                }
                $barom_hpa *= .01;
            #    print "temp $temp_f\n";
            #    print "rh $humidity\n";
                my $slp = (((($barom_hpa - .3) * (1+ (( ((1013.25 ** .190284)*.0065)/288 ) * ( 239.34/ (($barom_hpa-.3)**.190284) ))) ** (1/.190284)) - 2 ) * 0.02952998751);
            #    print "pressure $barom_hpa / $slp\n";
                my $dptf = $temp_f - ((9/25) * (100-$humidity));
            #    print "dpt $dptf\n";
                # wind 
                foreach my $sreading (@w_sensor_levels)
                {
                    if ($wind_direction < $sreading)
                    {
            #            warn "$wind_direction < $sreading";
                        $wind_deg = $sensor_to_direction{$sreading};
                        last;
                    }
                }

                my $t_rain = $client->get( 'local_rainin' ) || 0;
                print sprintf(" %6.2f | %6.2f | %5.1f | %4.2f | %03d  | %4.2f  ", $temp_f, $dptf, $humidity, $slp, $wind_deg, $t_rain ) . "\n";

                # send! (every 15 seconds to start)     
                if ($iter >= 15)
                {
                    print         "  Temp  | Dewpt  | RH    | SLP   | Wind | MPH \n";       
                    push(@l60,$r15);
                    shift(@l60);
                    my $l_60_toggles = reduce { $a + $b } @l60;
                    my $rain_60_calc = $l_60_toggles * 0.011;
                    $rain_60_calc ||= 0;

                    if (($today > $localdate) || ($first))
                    {
                        $client->set( local_rainin => '0' );
                        $localdate = $today;
                        $reset_counter = 1;
                        $first = 0;
                    }
                    elsif ($rain_in_24hour < $offset)
                    {
                        # ard rolled over
                        $offset = 0;
                    }
                   
                    if ($reset_counter)
                    {
                        $offset = $rain_in_24hour;
                        $reset_counter = 0;                              
                    }
 
                    my $todays_rain = $client->get( 'local_rainin' );
                    $client->set( local_rainin => (($todays_rain + $rain_in_24hour) - $offset) );

                    my $ws_mph_15 = (($t15 * 1.492) / 15);
                    my $pass = url_encode('L0ck3d!!');
                    my $dt = DateTime->now;
                    my $date = url_encode($dt->ymd . ' ' . $dt->hms);
                    my $urlstr = "http://rtupdate.wunderground.com/weatherstation/updateweatherstation.php?ID=KOHCINCI77&PASSWORD=$pass&dateutc=$date&tempf=" . 
                      url_encode($temp_f) . "&baromin=" .  url_encode($slp) . "&dewptf=" .  url_encode($dptf) . "&rainin=" . url_encode($rain_in_1hour) .
                    "&dailyrainin=" . url_encode($todays_rain) .
                    "&winddir=" .  url_encode($wind_deg) . "&windspeedmph=" .  url_encode($ws_mph_15) . "&windgustmph=" .  url_encode($wind_gust) .
                    "&humidity=" .  url_encode($humidity) . "&softwaretype=" .  url_encode("pi-weather-station") . "&action=updateraw&realtime=1&rtfreq=15";

            #        print $urlstr . "\n";
                    my $rs = $ua->get($urlstr);
            #        print $rs->content . "\n";
                    $iter = 0;
                    $t15 = 0;
                    $r15 = 0;

                    my $station = 'EW5253';
                    my $location = '3914.88N/08440.68W';
                    my $dt = DateTime->now;
                    my $data = $station . '>APRS,TCPIP*:@' . sprintf("%02d",$dt->day) . sprintf("%02d",$dt->hour) . 
                       sprintf("%02d",$dt->minute) . 'z' . $location . 
                       '_' . sprintf("%03d",$wind_deg) .
                       '/' . sprintf("%03d",$ws_mph_15) .
                       'g' . sprintf("%03d",$wind_gust) .
                       't' . sprintf("%03d",$temp_f) .
                       'r' . sprintf("%03s",$rain_in_1hour * .01) . 
        # last 24              'p' . sprintf("%03s",$ws_mph) . 
                       'P' . sprintf("%03d",0 * 100) .
                       'h' . sprintf("%02d",$humidity) .
                       'b' . sprintf("%05d",($slp * 33.8637526) * 10) .
                       'pi-weather-station-perl';

            #        warn $data;

                    if ($cwop <= 0)
                    {
                        eval {
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
                        };
                        warn $@ if $@;
                        $cwop = 1800;
                    }
                }
                $cwop--;
            }   
            else
            {
                warn "bad read";
            }   
            $buf = "";    
        }
        $skip = 0;
    }
  }
}

