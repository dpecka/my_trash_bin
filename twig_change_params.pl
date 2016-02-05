#!/usr/bin/perl
#
# use as:
# ./twig_change_params.pl '/Property/Property[@id="fuj"]' muehehe haha
#
#

use strict;
use warnings;
use XML::Twig;

my $twig = XML::Twig->new(
	pretty_print => 'indented',
);


$twig->parsefile($ARGV[0]) || die "can't open file: $ARGV[0]\n";

my ($_item_to_change) = $twig->findnodes($ARGV[1]);

$_item_to_change->set_att(
	$ARGV[2] => $ARGV[3],

);

$twig->flush;


exit 0;

