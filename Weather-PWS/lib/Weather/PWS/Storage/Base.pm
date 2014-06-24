package Weather::PWS::Storage::Base;

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

sub config
{
    my ($self, $conf) = @_;
    if (defined($conf))
    {
        $self->{_config} = $conf;
    }
    return $self->{_config};
}












1;
