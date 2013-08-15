package Message::Router;
{
  $Message::Router::VERSION = '1.132270';
}

use strict;use warnings;
use Message::Match qw(mmatch);
use Message::Transform qw(mtransform);
require Exporter;
use vars qw(@ISA @EXPORT_OK $config);
@ISA = qw(Exporter);
@EXPORT_OK = qw(mroute mroute_config);

sub mroute_config {
    my $new_config;
    eval {
        $new_config = shift
            or die 'single argument must be a HASH reference';
        die 'single argument must be a HASH reference'
            if shift;
        die 'single argument must be a HASH reference'
            if not $new_config or not ref $new_config eq 'HASH';
        die "passed config must hash an ARRAY 'routes' key"
            if not $new_config->{routes};
        die "passed config must hash an ARRAY 'routes' key"
            if not ref $new_config->{routes} eq 'ARRAY';
        foreach my $route (@{$new_config->{routes}}) {
            die "each route must be a HASH reference"
                if not $route;
            die "each route must be a HASH reference"
                if not ref $route eq 'HASH';
            die "each route has to have a HASH reference 'match' key"
                if not $route->{match};
            die "each route has to have a HASH reference 'match' key"
                if not ref $route->{match} eq 'HASH';
            if($route->{transform}) {
                die "the optional 'transform' key must be a HASH reference"
                    if ref $route->{transform} ne 'HASH';
            }
            if($route->{forwards}) {
                die "the optional 'forwards' key must be an ARRAY reference"
                    if ref $route->{forwards} ne 'ARRAY';
                foreach my $forward (@{$route->{forwards}}) {
                    die 'each forward must be a HASH reference'
                        if not $forward;
                    die 'each forward must be a HASH reference'
                        if ref $forward ne 'HASH';
                    die "each forward must have a scalar 'handler' key"
                        if not $forward->{handler};
                    die "each forward must have a scalar 'handler' key"
                        if ref $forward->{handler};
                }
            }
        }
    };
    if($@) {
        die "Message::Router::mroute_config: $@\n";
    }
    $config = $new_config;
    return $config;
}

sub mroute {
    eval {
        my $message = shift or die 'single argument must be a HASH reference';
        die 'single argument must be a HASH reference'
            unless ref $message and ref $message eq 'HASH';
        die 'single argument must be a HASH reference'
            if shift;
        foreach my $route (@{$config->{routes}}) {
            eval {
                if(mmatch($message, $route->{match})) {
                    if($route->{transform}) {
                        mtransform($message, $route->{transform});
                    }
                    if($route->{forwards}) {
                        foreach my $forward (@{$route->{forwards}}) {
                            no strict 'refs';
                            &{$forward->{handler}}(
                                message => $message,
                                route => $route,
                                routes => $config->{routes},
                                forward => $forward
                            );
                        }
                    }
                }
            };
            if($@) {
                die "Message::Router::mroute: $@\n";
            }
        }
    };
    if($@) {
        die "Message::Router::mmatch: $@\n";
    }
    return 1;
}
1;

__END__

=head1 NAME

Message::Router - Fast, simple message routing

=head1 SYNOPSIS

    use Message::Router qw(mroute mroute_config);

    sub main::handler1 {
        my %args = @_;
        #gets:
        # $args{message}
        # $args{route}
        # $args{routes}
        # $args{forward}
        print "$args{message}->{this}\n"; #from the transform
        print "$args{forward}->{x}\n";    #from the specific forward
    }

    mroute_config({
        routes => [
            {   match => {
                    a => 'b',
                },
                forwards => [
                    {   handler => 'main::handler1',
                        x => 'y',
                    },
                ],
                transform => {
                    this => 'that',
                },
            }
        ],
    });
    mroute({a => 'b'}); #prints 'that', and then 'y', per the handler1 sub

=head1 DESCRIPTION

This library allows fast, flexible and general message routing.

=head1 FUNCTION

=head2 mroute_config($config);

The config used by all mroute calls

=head2 mroute($message);

Pass $message through the config; this will emit zero or more callbacks.

=head1 TODO

A config validator.
Short-circuiting
More flexible match and transform configuration forms

=head1 BUGS

None known.

=head1 COPYRIGHT

Copyright (c) 2012, 2013 Dana M. Diederich. All Rights Reserved.

=head1 AUTHOR

Dana M. Diederich <diederich@gmail.com>

=cut

