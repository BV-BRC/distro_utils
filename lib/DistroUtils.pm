package DistroUtils;

use strict;
use File::Temp;
use Config::Simple;
use Template;

sub expand_template
{
    my($template_file, $include_path, $vars, $output) = @_;

    my $include_path = join(":", ".", @$include_path);
    my $tmpl = Template->new({
	ABSOLUTE => 1,
	INCLUDE_PATH => $include_path,
    });
    my $rc = $tmpl->process($template_file, $vars, $output);
    $rc or die "Failure processing $template_file: " . $tmpl->error();
}

sub expand_and_import
{
    my($template_file, $include_path, $vars) = @_;

    $vars //= {};

    my $tmp = File::Temp->new;
    expand_template($template_file, $include_path, $vars, $tmp);
    close($tmp);

    my %cfg;
    Config::Simple->import_from($tmp, \%cfg);

    my $client_key = "default.deploy-client";
    my $service_key = "default.deploy-service";
    my $master_key = "default.deploy-master";

    #
    # If the config file defines any of the deploy-* keys, then we assume it's
    # a standard config file that is driven from them.
    #
    # If none are defined, we assume the values for those lists
    # should be taken from the individual config stanzas.
    #
    
    if (exists($cfg{$client_key}) || exists($cfg{$service_key}) || exists($cfg{$master_key}))
    {
	#
	# Canonicalize.
	#
	for my $key ($client_key, $service_key, $master_key)
	{
	    my $val = $cfg{$key};
	    if (!ref($val))
	    {
		$cfg{$key} = defined($val) ? [$val] : [];
	    }
	}
    }
    else
    {
	#
	# Scan all blocks for _deploy_mode settings. Build
	#
	my %deploy;
	for my $k (keys %cfg)
	{
	    if ($k =~ /^([^.]+)\._deploy_mode$/)
	    {
		my $block = $1;
		my $mode = $cfg{$k};
		push(@{$deploy{$mode}}, $block);
		#
		# service mode implies client mode, for the
		# deployment of libraries etc
		#
		push(@{$deploy{client}}, $block) if $mode eq 'service';
	    }
	}
	for my $mode (qw(client service master))
	{
	    $cfg{"default.deploy-$mode"} = $deploy{$mode};
	}
	
    }
    return \%cfg;
}

1;

