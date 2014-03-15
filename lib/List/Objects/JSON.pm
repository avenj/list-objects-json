package List::Objects::JSON;
use strictures 1;

use Class::Method::Modifiers;
use List::Objects::WithUtils 'array', 'hash';

use parent 'JSON::Tiny';

around decode => sub {
  my ($orig, $self) = splice @_, 0, 2;
  my $res = $self->$orig(@_);
  ref $res eq 'ARRAY' ? $self->_decode_listobj_array($res)
    : ref $res eq 'HASH' ? $self->_decode_listobj_hash($res)
    : $res
};

sub _decode_listobj_array { array(@{ $_[1] }) }
sub _decode_listobj_hash  { hash(%{ $_[1] }) }

1;

=pod

=head1 NAME

List::Objects::JSON - Wrap List::Objects::WithUtils around JSON::Tiny

=head1 SYNOPSIS

  use List::Objects::JSON;
  use List::Objects::WithUtils;

  my $js = List::Objects::JSON->new;

  my $data  = array(qw/ foo bar baz /);
  my $bytes = $js->encode( $data->grep(sub { /^b/ }) );
  my $array = $js->decode($bytes);
  my $count = $array->count;  # 2

=head1 DESCRIPTION

This is a trivial subclass of L<JSON::Tiny>; it provides a C<decode> method
that produces L<List::Objects::WithUtils> B<array> and B<hash> objects when
deserializing data.

L<List::Objects::WithUtils> provides transparent serialization support via a
C<TO_JSON> method, but I found myself frequently typing something like:

  my $data  = $json->decode($foo);
  my $array = array(@$data);

... when I really just wanted the object representation all the time.

A subclass can override C<_decode_listobj_array> and C<_decode_listobj_hash>
appropriately to produce other object types. For example:

  # A subclass producing immutable data structures:
  package My::JSON::Immutable;
  use strictures 1;
  use List::Objects::WithUtils 2;
  use parent 'List::Objects::JSON';

  sub _decode_listobj_array { 
    my ($self, $item) = @_;
    immarray(@$item)
  }

  sub _decode_listobj_hash {
    my ($self, $item) = @_;
    immhash(%$item)
  }

  # A subclass that type-checks arrays:
  package My::JSON::CheckInt;
  use strictures 1;
  use List::Objects::WithUtils 2;
  use Types::Standard 'Int';
  use parent 'List::Objects::JSON';

  sub _decode_listobj_array {
    my ($self, $item) = @_;
    array_of Int() => @$item
  }

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut

# vim: ts=2 sw=2 et sts=2 ft=perl
