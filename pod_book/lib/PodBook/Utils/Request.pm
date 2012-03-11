package PodBook::Utils::Request;

use strict;
use warnings;

use CHI;         # for file caching
use File::Spec;  # for cross platform temp dir

# Constructor of this class
sub new {
    my (
        $self  , # object
        $uid   , # user id
        $source, # identifier (metacpan::modulename/upload)
        $type  , # mobi/epub
        $cache_namespace,
       ) = @_;

    # check the arguments!
    unless (defined $cache_namespace) {
        $cache_namespace = 'Mojolicious-PodBook-Request';
    }
    unless ($source =~ /^upload/ or $source =~ /^metacpan::/) {
        die ("Invalid source: $source");
    }

    # this gives me a path for temporary file storage, depending on OS
    my $tmpdir = File::Spec->tmpdir();

    # load the cache
    my $cache = CHI->new(
        driver   => 'File',
        root_dir => $tmpdir,
        namespace=> $cache_namespace,
    );

    my $ref = {
        # from interface
        uid           => $uid   ,
        source        => $source,
        type          => $type  ,

        # internal variables
        pod           => ''     ,
        book          => ''     ,
        cache         => $cache ,
        cache_key     => "$source--$type",
        uid_key       => "UID:$uid",
        uid_expiration=> 5,

        # state variables
        is_cached     => 0      ,
        pod_loaded    => 0      ,
        book_rendered => 0      ,
        };

    bless($ref, $self);
    return $ref;
}

sub uid_is_allowed {
    my ($self) = @_;

    if($self->{cache}->is_valid($self->{uid_key})) {
        return 0;
    }
    else {
        $self->{cache}->set($self->{uid_key},
                            '',
                            $self->{uid_expiration},
                            );
        return 1;
    }
}

sub is_cached {

    my ($self) = @_;

    if($self->{source} =~ /^upload/) {
        # upload content is never cached
        return 0;
    }

    if($self->{cache}->is_valid($self->{cache_key})) {
        $self->{is_cached} = 1; # true
        return 1;
    }
    else {
        $self->{is_cached} = 0; # false
        return 0;
    }
}

# ONLY NEEDED FOR A COMPLETE CLEARANCE OF CACHE!
sub clear_cache {
    my ($self) = @_;

    return $self->{cache}->clear();
}

sub cache_book {
    my ($self, $expires_in) = @_;

    $self->{cache}->set($self->{cache_key},
                        $self->{book},
                        $expires_in,
                        );
}

sub load_pod {

    my ($self) = @_;

    # fetch POD into global VAR
}

sub render_book {

    my ($self) = @_;

}

sub get_book {
    my ($self) = @_;

    return $self->get($self->{cache_key});

}

1;
