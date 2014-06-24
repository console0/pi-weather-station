package Weather::PWS::DataType::Coordinates;

use strict;
use parent qw( Weather::PWS::DataType::Base );

# lat / long cordinates 

sub decimal_latitude
{
    my ($self, $latitude) = @_;
    if (defined($latitude))
    {
        $self->{_latitude} = $latitude;
    }
    return $self->{_latitude};
}

sub decimal_longitude
{
    my ($self, $longitude) = @_;
    if (defined($longitude))
    {
        $self->{_longitude} = $longitude;
    }
    return $self->{_longitude};
}

sub altitude_meters
{
    my ($self, $altitude) = @_;
    if (defined($altitude))
    {
        $self->{_altitude} = $altitude;                                                                                           
    }
    return $self->{_altitude};
}

# once set, we can return the parts e/w/n/s or whatever
# so we dont have to worry about future integrations making
# life hard here (see CWOP LORAN retch formatting)

# as i find the need to get just fragments of data out ill 
# hack in the methods

sub altitude_feet                                                                                                                   
{   
    my $self = shift;
    my $alt = Math::BigFloat->new($self->{_altitude});
    $alt->bmul(3.28084);
    return $alt;
}

sub coordinates_degrees_minutes_seconds
{
    my ($self, $ignore) = @_;
    if ($ignore)
    {
        warn "You must set the coordinate in decimal first.";
    }

    return $self->latitude_dms . ", " . $self->longitude_dms;
}

sub coordinates_degrees_minutes
{
    my ($self, $ignore) = @_;
    if ($ignore)
    {
        warn "You must set the coordinate in decimal first.";
    }

    return $self->latitude_dm . ", " . $self->longitude_dm;
}

sub coordinates_decimal
{
    my ($self, $ignore) = @_;
    if ($ignore)
    {
        warn "You must set the coordinates in decimal first.";
    }

    return $self->{_latitude} . ", " . $self->{_longitude};
}

sub coordinates_aprswxnet
{
    my ($self, $ignore) = @_;
    if ($ignore)
    {
        warn "You must set the coordinates in decimal first.";
    }
    return $self->latitude_aprswxnet . ", " . $self->longitude_aprswxnet;
}

sub latitude_dms
{
    my $self = shift;
    if ($self->{_latitude} < 0)
    {
        return $self->decimal_coordinate_to_degrees_minutes_seconds($self->{_latitude} * -1) . 'S';
    }
    return $self->decimal_coordinate_to_degrees_minutes_seconds($self->{_latitude}) . 'N';
}

sub latitude_dm
{
    my $self = shift;
    if ($self->{_latitude} < 0)
    {
        return $self->decimal_coordinate_to_degrees_minutes($self->{_latitude} * -1) . 'S';
    }
    return $self->decimal_coordinate_to_degrees_minutes($self->{_latitude}) . 'N';
}

sub latitude_aprswxnet
{
    my $self = shift;
    if ($self->{_latitude} < 0)
    {
        return $self->decimal_coordinate_to_degrees_minutes_aprswxnet($self->{_latitude} * -1) . 'S';
    }
    return $self->decimal_coordinate_to_degrees_minutes_aprswxnet($self->{_latitude}) . 'N';
}

sub longitude_dms
{
    my $self = shift;
    if ($self->{_longitude} < 0)
    {
        return $self->decimal_coordinate_to_degrees_minutes_seconds($self->{_longitude} * -1) . 'W';
    }
    return $self->decimal_coordinate_to_degrees_minutes_seconds($self->{_longitude}) . 'E';
}

sub longitude_dm
{
    my $self = shift;
    if ($self->{_longitude} < 0)
    {
        return $self->decimal_coordinate_to_degrees_minutes($self->{_longitude} * -1) . 'W';
    }
    return $self->decimal_coordinate_to_degrees_minutes($self->{_longitude}) . 'E';
}

sub longitude_aprswxnet
{
    my $self = shift;
    if ($self->{_longitude} < 0)
    {
        return '0' . $self->decimal_coordinate_to_degrees_minutes_aprswxnet($self->{_longitude} * -1) . 'W';
    }
    return '0' . $self->decimal_coordinate_to_degrees_minutes_aprswxnet($self->{_longitude}) . 'E';
}

sub decimal_coordinate_to_degrees_minutes_seconds
{
    my ($self, $lat) = @_;
    my $dec_lat = Math::BigFloat->new($lat);
    my $dec = $dec_lat->copy->bmod($dec_lat->copy->as_int);
    my $min = $dec->copy->bmul(60);
    my $hmin = $min->copy->bmod($min->copy->as_int);
    my $sec = $hmin->copy->bmul(60);
    return $dec_lat->as_int . " " . $min->as_int . "' " . $sec . '"';
}

sub decimal_coordinate_to_degrees_minutes
{
    my ($self, $lat) = @_;
    my $dec_lat = Math::BigFloat->new($lat);
    my $dec = $dec_lat->copy->bmod($dec_lat->copy->as_int);
    my $min = $dec->copy->bmul(60);
    return $dec_lat->as_int . ' ' . $min . "'";
}  

sub decimal_coordinate_to_degrees_minutes_aprswxnet
{
    my ($self, $lat) = @_;
    my $dec_lat = Math::BigFloat->new($lat);
    my $dec = $dec_lat->copy->bmod($dec_lat->copy->as_int);
    my $min = $dec->copy->bmul(60);
    my $hmin = $min->copy->bmod($min->copy->as_int);
    my $sec = $hmin->copy->bmul(60);
    return $dec_lat->as_int . $min->as_int . "." . $sec->bround(2);
}







1;



1;
