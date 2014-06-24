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





1;
