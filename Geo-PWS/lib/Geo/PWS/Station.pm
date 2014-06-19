package Geo::PWS::Station;

use utf8;
use strict;
use warnings FATAL => 'all', NONFATAL => 'uninitialized';
use Math::BigFloat;
use POSIX qw(fmod);

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

sub altitude_meters
{
    my $self = shift;
    return $self->config->{altitude_meters};
}

sub altitude_feet
{
    my $self = shift;
    my $alt = Math::BigFloat->new($self->config->{altitude_meters});
    $alt->bmul(3.28084);
    return $alt;
}

# math/conversion routines
sub latitude_decimal
{
    my $self = shift;
    return $self->config->{latitude_decimal};
}

sub longitude_decimal
{
    my $self = shift;
    return $self->config->{longitude_decimal};
}

sub latitude_dms
{
    my $self = shift;
    if ($self->config->{latitude_decimal} < 0)
    {
        return $self->__convert_decimal_dms($self->config->{latitude_decimal} * -1) . 'S';
    }
    return $self->__convert_decimal_dms($self->config->{latitude_decimal}) . 'N';
}

sub latitude_dm
{
    my $self = shift;
    if ($self->config->{latitude_decimal} < 0)
    {
        return $self->__convert_decimal_dm($self->config->{latitude_decimal} * -1) . 'S';
    }
    return $self->__convert_decimal_dm($self->config->{latitude_decimal}) . 'N';
}

sub longitude_dms
{
    my $self = shift;
    if ($self->config->{longitude_decimal} < 0)
    {
        return $self->__convert_decimal_dms($self->config->{longitude_decimal} * -1) . 'W';
    }
    return $self->__convert_decimal_dms($self->config->{longitude_decimal}) . 'E';
}

sub longitude_dm
{
    my $self = shift;
    if ($self->config->{longitude_decimal} < 0)
    {
        return $self->__convert_decimal_dm($self->config->{longitude_decimal} * -1) . 'W';
    }
    return $self->__convert_decimal_dm($self->config->{longitude_decimal}) . 'E';
}

sub __convert_decimal_dms
{
    my ($self, $lat) = @_;
    my $dec_lat = Math::BigFloat->new($lat);
    my $dec = $dec_lat->copy->bmod($dec_lat->copy->as_int);
    my $min = $dec->copy->bmul(60);
    my $hmin = $min->copy->bmod($min->copy->as_int);
    my $sec = $hmin->copy->bmul(60);
    return $dec_lat->as_int . " " . $min->as_int . "' " . $sec . '"';
}

sub __convert_decimal_dm
{
    my ($self, $lat) = @_;
    my $dec_lat = Math::BigFloat->new($lat);
    my $dec = $dec_lat->copy->bmod($dec_lat->copy->as_int);
    my $min = $dec->copy->bmul(60);
    return $dec_lat->as_int . ' ' . $min . "'";
}  








1;
