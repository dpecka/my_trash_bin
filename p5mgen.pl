#!/usr/bin/perl
#
# usage /path/to/this/script /path/to/cfg_file -ARGx=val -ARGy=val
#
# /path/to/cfg_file is positional, must be first param
# -ARGx=val rewrites ARGx from cfg file with new value given on cmdline
#

use strict;
use warnings;
use File::Find;
use File::Spec;
use File::Basename qw(dirname);

my $cfg_file = shift;
my @cmd_args = @ARGV;

my %cfg_hash;
my %file_hash;

sub parse_cfg() {
	open(my $fh, "<", $cfg_file) || die "can't open: $cfg_file\n";
	$cfg_hash{'in'} = "none";
	my $_line_counter = 0;
	while(<$fh>) {
		$_line_counter++;

		## skip comments and blank lines and die on bad line
		next if m@^\s*#@;
		next if m@^$@;
#		die "cfg file syntax error on line $_line_counter\n" if ! m@^\w+\s+@;

		## switching to modes main/files
		if(m/^\@main$/) {
			$cfg_hash{'in'} = "main";
			next;
		};

		if(m/^\@files$/) {
			$cfg_hash{'in'} = "files";
			next;
		};

                if(m/^\@raw$/) {
                        $cfg_hash{'in'} = "raw";
                        next;
                };


		chomp;
		my @_disassembled_line = split(q/\s+/, $_, 2) if($cfg_hash{'in'} eq "main");
		$cfg_hash{$_disassembled_line[0]} = $_disassembled_line[-1] if($cfg_hash{'in'} eq "main");

		push(@{ $cfg_hash{'rewrite'} }, $_) if($cfg_hash{'in'} eq "files");
		push(@{ $cfg_hash{'raw'} }, $_) if($cfg_hash{'in'} eq "raw");
	};

};

sub modify_cfg_from_cli_args() {
	while(@cmd_args) {
		my $_arg = shift(@cmd_args);

		## die if arg ain't prepend with "-", removes "-" from ARGx
		die "bad command line argument: $_arg\n" if($_arg !~ m@^-\w+=.@);
		$_arg =~ s/^-//;

		my @_disassembled_arg = split(q/=/, $_arg, 2);
		$cfg_hash{$_disassembled_arg[0]} = $_disassembled_arg[-1];
	};
};

sub check_cfg() {
	my @_required_args = (
		"builddir",
		"targetdir",
		"version",
		"release"
	);
	foreach(@_required_args) {
		die "missing required variable: $_\n" if(!$cfg_hash{$_});
	};
};

sub build_filelist() {
	sub wanted() {
		push(@{ $file_hash{'filelist'} }, $File::Find::name);
		@{ $file_hash{"$File::Find::name"} } = stat($File::Find::name);
		
};
	
	find(\&wanted, $cfg_hash{'builddir'});
};

sub mogrify_filelist() {
	OUTERLOOP: foreach(@{ $file_hash{'filelist'} }) {

		## base settings
		my $_rpath = $_;
		$_rpath =~ s@^$cfg_hash{'builddir'}/?@@;
		my $_group = getgrgid($file_hash{$_}[5]);
		my $_mode = sprintf("%04o", $file_hash{$_}[2] & 07777);
		my $_owner = getpwuid($file_hash{$_}[4]);
		my $_path = "$cfg_hash{'targetdir'}/$_rpath";
		my $_inum = $file_hash{$_}[1];
		$_path =~ s@^/@@;
		my $_extra = "";

		## applying rewrite rules
		foreach(@{ $cfg_hash{'rewrite'} }) {
			my @_disassembled_rewrite_rule = split(q/,/);
			if($_disassembled_rewrite_rule[0] =~ s/^\-//) {
#				print "- $_path matches to $_disassembled_rewrite_rule[0]\n" if($_path =~ m@^$_disassembled_rewrite_rule[0]$@);
				next OUTERLOOP if($_path =~ m@^$_disassembled_rewrite_rule[0]/?$@);
			};

			if($_disassembled_rewrite_rule[0] =~ s/^\+//) {
#				print "+ $_path matches to $_disassembled_rewrite_rule[0]\n" if($_path =~ m@^$_disassembled_rewrite_rule[0]$@);
				next if($_path !~ m@^$_disassembled_rewrite_rule[0]/?$@);

				## kickout first
				shift(@_disassembled_rewrite_rule);
				foreach(@_disassembled_rewrite_rule) {

					if(m@^group=\w+$@) {
						$_group = +( split(q/=/) )[-1];
						next;
					};

					if(m@^mode=\w+$@) {
						$_mode = +( split(q/=/) )[-1];
						next;
					};

					if(m@^owner=\w+$@) {
						$_owner = +( split(q/=/) )[-1];
						next;
					};

					if(m@^path=.[^\s]+$@) {
						$_path = +( split(q/=/) )[-1];
						next;
					};

					$_extra .= " $_" if($_);
					
				};
			};
		};
		
		

		printf("dir group=%s mode=%s owner=%s path=%s%s\n", $_group, $_mode, $_owner, $_path, $_extra) if -d;
		printf("link path=%s target=%s\n", $_path, readlink($_)) if -l;

		if(-f "$_" && ! -l "$_") {
			if(exists($file_hash{'inums'}{$_inum})) {
#				printf("hardlink path=%s target=%s\n", $_path, $file_hash{'inums'}{$_inum});
				printf("hardlink path=%s target=%s\n", $_path, File::Spec->abs2rel($file_hash{'inums'}{$_inum}, dirname($_)));
			} else {
				$file_hash{'inums'}{$_inum} = $_;
                                printf("file %s group=%s mode=%s owner=%s path=%s%s\n", $_rpath, $_group, $_mode, $_owner, $_path, $_extra);
			};
		};
	};
	
};

sub append_mandatory() {
	print STDOUT << "EOF";
set name=pkg.fmri value=$cfg_hash{'name'}\@$cfg_hash{'version'}-$cfg_hash{'release'}
set name=pkg.description value=\"$cfg_hash{'description'}\"
set name=pkg.summary value=\"$cfg_hash{'summary'}\"
set name=pkg.arch value=$cfg_hash{'arch'}
set name=info.classification value=org.opensolaris.category.2008:System/$cfg_hash{'classification'}
EOF

};

sub append_raw() {
	foreach(@{ $cfg_hash{'raw'} }) {
		print "$_\n";
	};
};


### main()

parse_cfg();
modify_cfg_from_cli_args();
check_cfg();
build_filelist();
mogrify_filelist();
append_mandatory();
append_raw();

### debug
#printf(STDERR "%s\n", $_) foreach(keys(%file_hash));
#print "cfg vars:\n";
#print "\t$_ == $cfg_hash{$_}\n" foreach(grep(!/^in$/, keys(%cfg_hash)));
#print "\n";

#print "filelist:\n";
#print "\t$_\n" foreach(@{ $file_hash{'filelist'} });
#print "\n";

exit(0);
