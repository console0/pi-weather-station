#!/usr/bin/env perl

use Net::FTP;
my $image = '/home/pi/pi-weather-station/experimental/webcam/image.jpg';
my $pass = shift;

$ftp = Net::FTP->new("webcam.wunderground.com", Debug => 1);
$ftp->login("panzersnakeCAM1",$pass);
$ftp->cwd("/home/pi/pi-weather-station/experimental/webcam/");
$ftp->binary();
$ftp->put("/home/pi/pi-weather-station/experimental/webcam/image.jpg");
$ftp->quit;

