#!/usr/bin/perl
#
# usage:
#	/path/to/this/script keyword
#
# prints the list of the hd2 SAS characters sorted by a skill in keyword
# skills are: health, strength, endurance, shooting, stealth, medical, lockpick
#

use strict;
use warnings;

my $_key = shift;

chomp(my @all = <DATA>);

my $id = 0;
my %soldiers;
foreach(@all) {

	(
	$soldiers{$id}{"name"},
	$soldiers{$id}{"health"},
	$soldiers{$id}{"strength"},
	$soldiers{$id}{"endurance"},
	$soldiers{$id}{"shooting"},
	$soldiers{$id}{"stealth"},
	$soldiers{$id}{"medical"},
	$soldiers{$id}{"lockpick"}
	) = split(q/\s*\|\s*/, $_);

	$soldiers{$id}{"overall"}+=($soldiers{$id}{"$_"}=~s/[^\d]//rg) foreach("health", "strength", "endurance", "shooting", "stealth", "medical", "lockpick");
	$id++;
};


##header
printf("%-32s%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
	"NAME",
	"HEALTH",
	"ENDURAN",
	"SHOOTIN",
	"STEALTH",
	"MEDICAL",
	"LOCKPIC",
	"OVERALL"
);

print "-" foreach(0..31+7*8);
print "\n";


foreach(sort { $soldiers{$b}{"$_key"}=~s/[^\d]//rg <=> $soldiers{$a}{"$_key"}=~s/[^\d]//rg } keys(%soldiers)) {

	printf("%-32s%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
		$soldiers{$_}{"name"},
		$soldiers{$_}{"health"},
		$soldiers{$_}{"endurance"},
		$soldiers{$_}{"shooting"},
		$soldiers{$_}{"stealth"},
		$soldiers{$_}{"medical"},
		$soldiers{$_}{"lockpick"},
		$soldiers{$_}{"overall"}
	);

};

exit 0;

__DATA__
DOUGLAS LAUER        |515| 21kg| 75| 75%| 37%| 15%| 70%|
JOHN (SMITHY) GLESBY |585| 25kg| 45| 71%| 79%| 35%| 17%|   
ROBERT CZAKOWSKI     |545| 25kg| 68| 79%| 54%| 10%| 11%|
HERBERT (DOC) BENNETT|555| 25kg| 36| 70%| 35%| 85%| 43%|
SIEGFRIED HIRSCH     |600| 27kg| 32| 82%| 52%| 10%| 22%|
DANIEL OSULLIVAN     |645| 24kg| 63| 67%| 53%| 10%| 26%| 
GREGORY (JOCK) DEAN  |570| 25kg| 70| 68%| 25%| 48%| 32%|
ARTHUR MUNCIE        |545| 23kg| 34| 78%| 58%| 58%| 10%|
PATRICK MULLHOLAND   |575| 21kg| 60| 72%| 60%| 10%| 56%|
JAMES THOMAS RUSSEL  |635| 25kg| 48| 71%| 44%| 10%| 56%|
JULIAN CUNNINGHAM    |595| 22kg| 55| 70%| 39%| 60%| 19%|
FREDERICK MALLORY    |560| 21kg| 80| 65%| 63%| 25%| 48%|
JAN KRATOCHVIL       |605| 30kg| 28| 73%| 31%| 30%| 75%|
DAVID FOREMAN        |535| 25kg| 49| 74%| 68%| 55%| 15%|
WILLIAM BROADHURST   |540| 22kg| 78| 71%| 80%| 12%| 12%|
GEORGE WINGATE       |575| 34kg| 25| 72%| 49%| 43%| 45%|
JAMES (ANGEL) SAUNBY |580| 31kg| 77| 61%| 42%| 20%| 33%|
ANDREW HARRIS        |520| 29kg| 26| 85%| 71%| 10%| 50%|
SIMON FINCH          |550| 21kg| 64| 65%| 77%| 50%| 30%|
PETER ASH            |580| 25kg| 50| 74%| 57%| 18%| 35%|
ROGER JENKINS        |610| 30kg| 31| 86%| 25%| 30%| 40%|
THOMAS WRIGHT        |565| 32kg| 29| 83%| 55%| 10%| 20%|    
PAUL (SCOUSE) TATNELL|615| 25kg| 39| 62%| 62%| 82%| 23%|
LARRY SMITH          |570| 33kg| 40| 63%| 48%| 65%| 41%|
IRWIN CARLYSLE       |550| 21kg| 56| 77%| 75%| 10%| 60%|
BASIL ELLIOT         |525| 24kg| 65| 73%| 69%| 22%| 38%|
ROGER HENDRY         |560| 23kg| 72| 78%| 46%| 10%| 13%|
GEORGE (FLASH) BURTON|530| 29kg| 41| 70%| 73%| 39%| 55%|
HARRY (COAL) COLLINS |620| 25kg| 52| 69%| 33%| 33%| 28%|
KEVIN TURNER         |630| 28kg| 59| 66%| 28%| 35%| 25%|
