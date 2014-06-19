#!/usr/bin/env perl

use strict;
use lib './lib';
use Geo::PWS;

use Data::Dumper;

# could have multiple stations, in case you were doing that
my $p = Geo::PWS->new( config => './pws.yaml' );
my $station = $p->station('EW5253');

print "Station Details: " . $station->name . "\n";
print "Decimal:     " . $station->latitude_decimal . " " . $station->longitude_decimal . "\n";
print "Deg/Min:     " . $station->latitude_dm . " " . $station->longitude_dm . "\n";
print "Deg/Min/Sec: " . $station->latitude_dms . " " . $station->longitude_dms . "\n";
print "Altitude:    " . $station->altitude_meters . " Meters / ". $station->altitude_feet . " Feet\n";

# adding data
# multi sensors
##$station->add_data( in_hg => '30.01', temp_f => '75.6', wind_mph => '1.1' );

# single sensor

##$station->in_hg('30.01');

# Later... sending reports or reading data

##print "Current (Latest) Temp: " . $station->temp_c . "\n";
##my $report = $station->send_report( integration => 'CWOP' );


