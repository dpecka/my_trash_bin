#!/usr/bin/perl
#
# usage: yum -q list --showduplicates | /path/to/this/script
#
# tested on el6 (centos/rhel)
#

use strict;
use warnings;

chomp(my @__input = <>);
my @_postprocessed_input;

my $counter = "-1";
while(@__input) {
        $counter++;
        my $item = shift(@__input);
        if($item =~ /^\s+/) {
                $_postprocessed_input[-1] .= "\t$item";
                next;

        };
        push(@_postprocessed_input, $item);
};

undef(@__input);

my $_pkg_status = "?";

foreach(@_postprocessed_input) {
        if(/^Installed/) { $_pkg_status = "i"; next; };
        if(/^Available/) { $_pkg_status = "a"; next; };
        print join(";", split(/\s+/), "$_pkg_status"), "\n";
};

exit 0;
