use Device::SerialPort::Arduino;
use DateTime;
use List::Util qw(sum max);

my $left = 720;

  my $ard = Device::SerialPort::Arduino->new(
    port     => '/dev/ttyACM0',
    baudrate => 9600,

    databits => 8,
    parity   => 'none',
  );

my @dir = (26, 45, 77, 118, 161, 196, 220, 256);
my $dhash = { 26 => '270', 45 => '315', 77 => '0',
              118 => '225', 161 => '45', 196 => '180',
              220 => '135', 256 => '90' };
my $hashnames = { 0 => 'N', 45 => 'NE', 90 => 'E', 135 => 'SE', 180 => 'S', 225 => 'SW', 270 => 'W', 315 => 'NW' };
my $ctr_15 = 0;
my $ctr_60_gust = 0;
my $ctr_2m = 0;
my $ctr_10m = 0;

my @avg_mph_15_sec = (); # 3 positions (2)
my @mph_60_gust = (); # 12 positions (11)
my @avg_mph_2_min = (); # 24 positions (23)
my @avg_mph_10_min = (); # 120 positions (119)

my $fl = 0;
while (1)
{
  $left --;
  exit if $left <= 0;
  my $dt = DateTime->now;
  $dt->set_time_zone('America/New_York');
  my $of = './' . $dt->ymd . '/' . $dt->hour . ".log";
  if (!-d './' . $dt->ymd)
  {
     warn "new day dir";
     system ("mkdir ./" . $dt->ymd);
  }
  my $line = $ard->receive();
  if (($line) && ($fl))
  {
#    warn $line . "\n";
#    system ("echo \'$line\' >> $of");

    my ($rawwd,$rawws,$rawbuk) = split(/\|/,$line);
    my ($r1,$dirr) = split(/:/,$rawwd);
    my ($r2,$ws) = split(/:/,$rawws);
    my ($r3,$rs) = split(/:/,$rawbuk);
    $dirr >>= 2;
    my @listr = sort { abs($a - $dirr) <=> abs($b - $dirr) } @dir;

    $ctr_15++; #incr
    if ($ctr_15 == 3)
    { 
       $ctr_15 = 0;
    }

    $ctr_60_gust++; # incr
    if ($ctr_60_gust == 12)
    {
       $ctr_60_gust = 0;
    }

    @avg_mph_15_sec[$ctr_15] = $ws;
    @mph_60_gust[$ctr_60_gust] = $ws;

    # 60 ticks min = 1.492
    # avg ticks per 15 seconds * 4 / 60 * 1.492 = calced speed 
    my $rt_avg = sprintf("%0.1f",(((sum(@avg_mph_15_sec)/@avg_mph_15_sec) * 12) / 60) * 1.492); # avg num pulses per 15 sec * .746 mph per tick
    #warn "rolling ws avg (15 sec, pos $ctr_15) $rt_avg";

    my $max_past_60 = max(@mph_60_gust);
    my $gusts = sprintf("%0.1f",(($max_past_60 * 12) / 60) * 1.492);
    #warn "rolling 60 sec gust (5 sec, pos $ctr_60_gust) $gusts";

    # precip rate/hr is rawbuk (5 sec ticks) * 12 / 60 * 0.011   
    my $current_precip_rate = sprintf("%0.01f",(($rs * 12) / 60) * 0.011);

    #ok, assuming we have a blip, add to rain.ticks for $dt->ymd
    if ($rs)
    {
         my $r_of = './' . $dt->ymd . '/daily_rain_ticks.log';
	 system("echo \'$dt|$rs\' >> $r_of"); # can be summed later
    }

    # rot dhash 180, sensor seems to be off backwards'
    my $diradj = $dhash->{$listr[0]} + 180;
    $diradj = $diradj - 360 if $diradj >= 360;
   # print "[$left] Closest to $dirr: $listr[0] ( $dhash->{$listr[0]} ) rot 180 to wind from $diradj\n";
    system("echo \'$diradj:$rt_avg:$gusts:$current_precip_rate\' > current.wind");
    print "[$left] $dt: Wind $hashnames->{$diradj} ($diradj deg) at $rt_avg MPH (Gusting to $gusts MPH)\n";
  }

  else
  {
    warn "disacrd firstline";
  }
  $fl=1;
}
