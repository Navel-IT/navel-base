# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Base::Daemon::Parser 0.1;

use Navel::Base;

use parent qw/
    Navel::Base::Definition::Parser::Reader
    Navel::Base::Definition::Parser::Writer
/;

use Navel::Base::Definition;

#-> methods

sub new {
    my $class = shift;

    bless {
        definition => {},
        file_path => undef
    }, ref $class || $class;
}

sub validate {
    my ($class, %options) = @_;

    Navel::Base::Definition->validate(
        definition_class => __PACKAGE__,
        validator => $options{validator},
        raw_definition => $options{raw_definition}
    );
}

sub set_definition {
    my ($self, $value) = @_;

    my $errors = $self->validate($value);

    die $errors if @{$errors};

    $self->{definition} = $value;

    $self;
}

sub read {
    my $self = shift;

    $self->set_definition($self->SUPER::read(@_));

    $self;
}

sub write {
    my $self = shift;

    $self->SUPER::write(
        definitions => $self->{definition},
        @_
    );

    $self;
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Base::Daemon::Parser

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
