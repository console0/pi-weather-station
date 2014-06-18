package Geo::PWS::Configuration;

use strict;
use warnings FATAL => 'all', NONFATAL => 'uninitialized';

sub new
{
    my ($class, %args) = @_;
    my $self = {};
    bless $self, $class;
    
    while (my ($k,$V) = each(%args))
    {
        if ($self->can($k))
        {
            $self->$k($v);
        }
    }

    return $self;
}













1;
