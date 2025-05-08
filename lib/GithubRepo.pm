package GithubRepo;

use Carp::Always;
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
    $self->{ua}->default_header(Accept => "application/vnd.github.v3+json");

    return bless $self, $class;
}

sub get_branch
{
    my($self, $branch) = @_;

    my $url = $self->url_base . "/repos/" . $self->repo . "/branches/$branch";
    my $data = $self->retrieve($url);

    return $data;
}

sub get_branch_commit
{
    my($self, $branch) = @_;

    my $url = $self->url_base . "/repos/" . $self->repo . "/commits/$branch";
    my $data = $self->retrieve($url);

    return $data;
}

sub compare_commits
{
    my($self, $c1, $c2) = @_;
    
    my $url = $self->url_base . "/repos/" . $self->repo . "/compare/$c1...$c2";
    my $data;
    eval {
	$data = $self->retrieve($url);
    };
    return $data;
}

sub get_commit
{
    my($self, $hash) = @_;
    
    my $url = $self->url_base . "/repos/" . $self->repo . "/git/commits/$hash";
    my $data;
    eval {
	$data = $self->retrieve($url);
    };
    return $data;
}

sub get_tree
{
    my($self, $hash) = @_;
    
    my $url = $self->url_base . "/repos/" . $self->repo . "/git/trees/$hash";
    my $data;
    eval {
	$data = $self->retrieve($url);
    };
    return $data;
}

sub get_pull
{
    my($self, $pull) = @_;
    
    my $url = $self->url_base . "/repos/" . $self->repo . "/pulls/$pull";
    my $data;
    eval {
	$data = $self->retrieve($url);
    };
    return $data;
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

sub get_contributors
{
    my($self) = @_;

    my $url = $self->url_base . "/repos/" . $self->repo . "/contributors";
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
