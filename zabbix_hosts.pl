#!/usr/bin/perl

use strict;
use warnings;
use File::Basename qw(dirname);
use lib dirname($0);
use RPC::Legacy::Client;
use JSON;
use File::Slurp qw/slurp/;
#use Data::Dumper;

# die of incorrect number of cli params
help() if(!$ARGV[3]);


### params handling
my $action = shift; ## available actions: get_hosts, delete_hosts, import_hosts
my $username = shift;
my $pass = shift;
my $uri = shift;

#########################################################
### Main script

# logout
my $client = new JSON::RPC::Legacy::Client; 
my $auth_hash = login();

my $_action_done;

get_hosts(@ARGV) if($action eq "get_hosts");
delete_hosts(@ARGV) if($action eq "delete_hosts");
import_hosts(@ARGV) if($action eq "import_hosts");


## logout and/or help if bad params
help() if(!$_action_done);
logout();

exit 0;

#########################################################
### Function + sub block

sub help {
	printf << 'EOF';

usage:		./this_script <action> username pwd json_uri @action_params

actions:	get_hosts, delete_hosts, import_hosts

rationale:	all params are positional and at least an "action", "username", "pwd"
		and "json_uri" are always required. Actions expect following additional
		parameters:

		get_hosts:	no additional params
		delete_hosts:	list of hosts IDs to remove - can be get using get_hosts()
		import_hosts:	path to valid xml file to import into a zabbix

example:	./this_script import_hosts \
			admin zabbix \
			http://localhost/zabbix/api_jsonrpc.php \
			/tmp/x.xml

		First line is obvious, on second line is user/pwd, third line is json_uri
		and fourth line is import_hosts specific parameter ..


EOF

exit 1;


};

## login
sub login {
	my $json_obj = {
		jsonrpc => "2.0",
		method => "user.login",
		params => {
			user => "$username",
			password => "$pass",
  		},
		id => "1",
	};

	my $response = $client->call($uri, $json_obj);
	die "user.login failed\n" unless $response->content->{"result"};
};

# Logout from Zabbix
sub logout {
	my $json_obj = {
		jsonrpc => "2.0",
		method => "user.logout",
		params => [],
		auth => "$auth_hash",
		id => "1",
	};
	my $response = $client->call($uri, $json_obj);
	die "user.logout failed\n" unless $response->content->{"result"};
};

sub get_hosts {
	my $json_obj = {
		jsonrpc	=> "2.0",
		method	=> "host.get",
		params => {
			output => ["hostid","name"],
			sortified => "name"
			},
		id => "1",
	auth => "$auth_hash",
	};
	
	my $response = $client->call($uri, $json_obj);
	die "host.get failed\n" unless $response->content->{"result"};
	$_action_done = "yes";
	printf("%-24s\t%s\n", $_->{"hostid"}, $_->{"name"}) foreach( @{ $response->content->{"result"} } );

};

sub delete_hosts {
	my $json_obj = {
                jsonrpc => "2.0",
                method => "host.delete",
                params => [ @ARGV ],
                auth => "$auth_hash",
                id => "1",

	};
	my $response = $client->call($uri, $json_obj);
	die "host.delete failed\n" unless $response->content->{"result"};
	$_action_done = "yes";
};

sub import_hosts {
	my $slurped_content = slurp(shift) || die "can't open file: $!\n";
	$slurped_content =~ s/\n//g;

	my $json_obj = {
		jsonrpc => "2.0",
		method => "configuration.import",
		params => {
			format => "xml",
			rules => {
				groups => {
				createMissing => "true",
				},

			hosts => {
				createMissing => "true",
				updateExisting => "true",
				},

			templates => {
				createMissing => "false",
				updateExisting => "false",
				},

			templateScreens => {
				createMissing => "false",
				updateExisting => "false",
				},

			templateLinkage => {
				createMissing => "true",
				},

			items => {
				createMissing => "true",
				updateExisting => "true",
				},

			discoveryRules => {
				createMissing => "true",
				updateExisting => "true",
				},

			triggers => {
				createMissing => "true",
				updateExisting => "true",
				},

			graphs => {
				createMissing => "true",
				updateExisting => "true",
				},

			},
		source => "$slurped_content"
		},
		auth => "$auth_hash",
		id => "1",
	};
	my $response = $client->call($uri, $json_obj);
	die "configuration.import failed\n" unless $response->content->{"result"};
	$_action_done = "yes";
};

