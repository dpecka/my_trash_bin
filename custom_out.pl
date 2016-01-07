#!/usr/bin/perl
#
# example usage:
#       > ./this_script "%-2{param1}%{param0}\n" a b
#       > b a
#
# rationale:
#
# - shift first param as format to $format
# - map other params to param0..N (eg after shift $ARGV[N] will be $pool{"paramN"}
# - build from $format a printf line within the printf_in_format function
#

use strict;
use warnings;

#
# could be something like "%-33{param1}%{param0}"
#
(my $format = shift)=~s/(\\.)/qq("$1")/eeg;

#
# the rest for a print to %pool
#
my %pool;
my $_id = 0;
while(@ARGV) {
        $pool{"param$_id"} = shift @ARGV;
        $_id++;
};


#
# usage: printf_in_format $format
#
sub printf_in_format {
  ### HERE IS YOUR FUCKING FISH
  my ($str) = shift;
  my @params;
  $str =~ s/(%[^{]*) \{ ([^{]+) \}/push @params, $pool{$2}; $1 . 's'/gex;
#  print "## debug: $str\n";
  printf("$str", @params);
};


printf_in_format($format);

exit 0;
