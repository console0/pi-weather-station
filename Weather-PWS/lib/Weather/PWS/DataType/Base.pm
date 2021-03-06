package Weather::PWS::DataType::Base;

use strict;
use warnings FATAL => 'all', NONFATAL => 'uninitialized';

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

    return $self;
}













1;
