#!/usr/bin/perl
#
# use as:
# ./twig_change_values.pl '/Property/Property[@id="1"]/Property' ueee
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

$_item_to_change->set_text(
	$ARGV[2],

);

$twig->flush;


exit 0;

