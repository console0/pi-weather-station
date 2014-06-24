#!/usr/bin/env perl

use strict;
use lib './lib';
use Weather::PWS;

use Data::Dumper;

# could have multiple stations, in case you were doing that
my $p = Weather::PWS->new( config => './pws.yaml' );
my $station = $p->station('EW5253');

print "Example - Usage of the PWS code\n\n";
print "Station Details         : " . $station->name . "\n";
print "Decimal Coordinates     : " . $station->location->coordinates_decimal . "\n";
print "Deg/Min Coordinates     : " . $station->location->coordinates_degrees_minutes . "\n";
print "Deg/Min/Sec Coordinates : " . $station->location->coordinates_degrees_minutes_seconds . "\n";
print "APRSWXNET Coordinates   : " . $station->location->coordinates_aprswxnet . "\n";
print "Altitude                : " . $station->location->altitude_meters . " Meters / ". $station->location->altitude_feet . " Feet\n\n";
print "Storage Engine          : " . ref($station->storage) . "\n";
print "Storage Path            : " . $station->storage->path . "\n\n";

print "Station Sensors Enabled\n";
foreach my $sensor (@{$station->sensors})
{
    print "$sensor (" . $station->sensor_info($sensor) . ")\n";
}
print "\n";

# adding data
# multi sensors
##$station->add_data( in_hg => '30.01', temp_f => '75.6', wind_mph => '1.1' );

# single sensor

##$station->in_hg('30.01');

# Later... sending reports or reading data

##print "Current (Latest) Temp: " . $station->temp_c . "\n";
##my $report = $station->send_report( integration => 'CWOP' );


