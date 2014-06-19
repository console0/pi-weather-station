package Geo::PWS;

use 5.010000;
use strict;
use warnings FATAL => 'all', NONFATAL => 'uninitialized';
use YAML qw( LoadFile Dump );
use Data::Dumper;

use Geo::PWS::Station;

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

    my $config_file = $self->config();
    if (!$config_file)
    {
        die("config file not specified");
    }

    if (-f $config_file)
    {
        my $conf = LoadFile($config_file);
        $self->loaded_conf($conf);
    }
    else
    {
        die("config file was empty");
    }

    return $self;
}

sub station
{
    my ($self, $station) = @_;
    my $station_ob = Geo::PWS::Station->new( config => $self->loaded_conf->{pws}->{stations}->{$station} );
    return $station_ob;
}


# quick/dirty accessor splat
sub config { my ($self, $val) = @_; $self->{_config} = $val if defined $val; return $self->{_config}; }
sub loaded_conf { my ($self, $val) = @_; $self->{_loaded_config} = $val if defined $val; return $self->{_loaded_config}; }











1;
