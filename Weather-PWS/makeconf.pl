


my $conf = {};
$conf->{'pws'} = {};
$conf->{'pws'}->{stations} = {};
$conf->{pws}->{stations}->{'EW5253'} = {};
$conf->{pws}->{stations}->{'EW5253'}->{'altitude_meters'} = '239.4';
$conf->{pws}->{stations}->{'EW5253'}->{'latitude_decimal'} = '39.248';
$conf->{pws}->{stations}->{'EW5253'}->{'longitude_decimal'} = '-84.678';
$conf->{pws}->{stations}->{'EW5253'}->{'storage_engine'} = 'File';
$conf->{pws}->{stations}->{'EW5253'}->{'name'} = 'CWOP EW5253 / Weather Underground PWS KOHCINCI77';

use YAML qw( Dump );

print Dump($conf);
