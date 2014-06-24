package Weather::PWS::Station;

use utf8;
use strict;
use warnings FATAL => 'all', NONFATAL => 'uninitialized';
use Math::BigFloat;
use POSIX qw(fmod);

use Weather::PWS::DataType::Coordinates;

sub new
{
    my ($class, %args) = @_;
    my $self = {};
    bless $self, $class;
    
    while (my ($k,$v) = each(%args))
    {
        if ($self->can($k))
        {
            $self->$k($v);
        }
    }

    if (!$self->config)
    {
        die "Missing configuration for station";
    }

    # We use data types instead of raw data values, that way the conversions from
    # unit to unit can happen in the data types themselves, and the code to do
    # stuff like altimiter settings for reporting pressure can just work the same

    # we need a "location", a set of coordinates (decimal is easy to get from google maps)
    # note that the station location also has an altitude!
    $self->{_location} = Weather::PWS::DataType::Coordinates->new( 
                                    decimal_latitude => $self->config->{latitude_decimal},
                                    decimal_longitude => $self->config->{longitude_decimal},
                                    altitude_meters => $self->config->{altitude_meters},
                         );
    # ok, we also need to fire up the "storage engine"
    my $storage_class = 'Weather::PWS::Storage::' . $self->config->{storage}->{engine};
    eval "require $storage_class; 1;";
    if ($@)
    {
        warn $@;
        die("Could not require() in the storage class requested");
    }
    $self->{_storage} = $storage_class->new( config => $self->config->{storage} );

    return $self;
}

# quick/dirty accessor splat
sub config { my ($self, $val) = @_; $self->{_config} = $val if defined $val; return $self->{_config}; }

# config print
sub name
{
    my $self = shift;
    return $self->config->{name};
}

sub location
{
    my $self = shift;
    return $self->{_location};
}

sub storage
{
    my $self = shift;
    return $self->{_storage};
}

# Will probably add more as i go
my @possible_sensors = qw( pressure humidity temperature anemometer wind_vane rain_gauge solar radiation );
                           
sub sensors
{
    my ($self) = shift;
    my @enabled;
    foreach my $sensor (@possible_sensors)
    {
        if (exists $self->config->{sensors}->{$sensor})
        {
            push(@enabled,$sensor);
        }
    }
    return \@enabled;
}

sub sensor_info
{
    my ($self,$sensor) = @_;
    return $self->config->{sensors}->{$sensor};
}

1;
