package Dancer::Session::YAML;

use strict;
use warnings;
use base 'Dancer::Session::Abstract';

use Dancer::Config 'setting';
use Dancer::FileUtils 'path';

# static

sub init {
    my ($class) = @_;

    # default value for session_dir
    setting('session_dir' => path(setting('appdir'), 'sessions'))
        if not defined setting('session_dir');
    
    # make sure session_dir exists
    my $session_dir = setting('session_dir');
    if (! -d $session_dir) {
        mkdir $session_dir 
            or die "session_dir $session_dir cannot be created";
    }
    Dancer::Logger->debug("session_dir : $session_dir");
}

# create a new session and return the newborn object
# representing that session
sub create {
    my ($class) = @_;

    my $self = Dancer::Session::YAML->new;
    $self->flush;
    return $self;
}

# Return the session object corresponding to the given id
sub retreive($$) {
    my ($class, $id) = @_;

    return undef unless -f $self->yaml_file;
    return YAML::LoadFile($self->yaml_file);
}

# instance 

sub yaml_file {
    my ($self) = @_;
    return path(setting('session_dir'), $self->id.'.yml');
}

sub destroy {
    my ($self) = @_;
    unlink $self->yaml_file if -f $self->yaml_file;
}

sub flush {
    my $self = shift;
    open SESSION, '>', $self->yaml_file or die $!;
    print SESSION YAML::Dump($self);
    close SESSION;
    return $self;
}

1;
__END__
=pod

=head1 NAME

Dancer::Session::YAML - YAML-file-based session backend for Dancer

=head1 DESCRIPTION

This module implements a session engine based on YAML files. Session are stored
in a I<session_dir> as YAML files. The idea behind this module was to provide a
transparent session storage for the developer. 

This backend is intended to be used in development environments, when looking
inside a session can be useful.

It's not recommended to use this session engine in production environements.

=head1 CONFIGURATION

The setting B<session> should be set to C<yaml> in order to use this session
engine in a Dancer application.

Files will be stored to the value of the setting C<session_dir>, which default value is
C<appdir/sessions>.

Here is an example configuration that use this session engine and stores session
files in /tmp/dancer-sessions

    session: "yaml"
    session_dir: "/tmp/dancer-sessions"

=head1 DEPENDENCY

This module depends on L<YAML>.

=head1 AUTHOR

This module has been written by Alexis Sukrieh, see the AUTHORS file for
details.

=head1 SEE ALSO

See L<Dancer::Session> for details about session usage in route handlers.

=head1 COPYRIGHT

This module is copyright (c) 2009 Alexis Sukrieh <sukria@sukria.net>

=head1 LICENSE

This module is free software and is released under the same terms as Perl
itself.

=cut