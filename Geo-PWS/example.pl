#!/usr/bin/env perl

use strict;
use lib './lib';
use Geo::PWS;

# could have multiple stations, in case you were doing that
my $p = Geo::PWS->new( config => '.pws' );
my $station = $p->station('EW5253');

# adding data
# multi sensors
$station->add_data( in_hg => '30.01', temp_f => '75.6', wind_mph => '1.1' );
# single sensor
$station->in_hg('30.01');

# Later... sending reports or reading data
print "Current (Latest) Temp: " . $station->temp_c . "\n";
my $report = $station->send_report( integration => 'CWOP' );


