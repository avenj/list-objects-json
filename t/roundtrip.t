use Test::More;
use strict; use warnings FATAL => 'all';

use List::Objects::JSON;
use List::Objects::WithUtils 2;

my $js = List::Objects::JSON->new;

{
  my $array = array( 1 .. 3, array(4,5) );
  my $json  = $js->encode($array);
  my $back  = $js->decode($json);
  is_deeply
    [ $back->all ],
    [ $array->all ],
    'roundtripped array ok';
}

{
  my $hash = hash( foo => 1, bar => hash(baz => 1) );
  my $json = $js->encode($hash);
  my $back = $js->decode($json);
  is_deeply
    +{ $back->export },
    +{ $hash->export },
    'roundtripped hash ok';
}


done_testing;
