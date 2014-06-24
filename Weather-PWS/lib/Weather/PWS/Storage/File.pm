package Weather::PWS::Storage::File;

use strict;
use warnings FATAL => 'all', NONFATAL => 'uninitialized';
use parent qw( Weather::PWS::Storage::Base );

sub path
{
    my $self = shift;
    return $self->config->{path};
}









1;
