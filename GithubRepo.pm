package GithubRepo;

use strict;
use Data::Dumper;
use LWP::UserAgent;
use JSON::XS;
use MIME::Base64;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw(repo ua json url_base token));

sub new
{
    my($class, $repo, $token) = @_;
    
    my $self = {
	repo => $repo,
	ua => LWP::UserAgent->new,
	json => JSON::XS->new->pretty(1),
	url_base => "https://api.github.com",
	token => $token,
    };

    if ($token)
    {
	$self->{ua}->default_header( Authorization => "token " . $token);
    }

    return bless $self, $class;
}

sub get_master_hash
{
    my($self) = @_;

    my $url = $self->url_base . "/repos/" . $self->repo . "/commits/master";
    my $data = $self->retrieve($url);

    if (!exists($data->{sha}))
    {
	die "get_master_hash: no sha found in data\n" . Dumper($data);
    }

    return $data->{sha};
}

sub get_dependencies
{
    my($self, $commit) = @_;

    my $url = $self->url_base . "/repos/" . $self->repo . "/contents/DEPENDENCIES?ref=$commit";
    my $data;
    eval {
	$data = $self->retrieve($url);
    };
    $data or return ();
    my $content = $data->{content};
    $content or return ();
    my $file = decode_base64($content);
    my @list = $file =~ /(\S+)/g;
    return @list;
}

sub get_info
{
    my($self) = @_;

    my $url = $self->url_base . "/repos/" . $self->repo;
    my $data = $self->retrieve($url);

    return $data;
    
}

sub retrieve
{
    my($self, $url) = @_;

    my $res = $self->ua->get($url);
    $res->is_success or die "Failure retrieving $url: " . $res->content;
    my $data = $self->json->decode($res->content);
    return $data;
}

1;
