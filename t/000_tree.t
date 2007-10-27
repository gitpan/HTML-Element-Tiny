use strict;
use warnings;
use Test::More 'no_plan';

BEGIN { use_ok('HTML::Element::Tiny') }

my $tree = HTML::Element::Tiny->new(
  [ div =>
    [ ul => { id => 'mylist', class => 'menu foo' },
      map({ [ li => "hello $_" ] } qw(alice bob sue trent)),
    ],
  ]
);

is($tree->parent, undef, 'no parent for root');
is(
  scalar $tree->children, 1,
  "root has one child",
);

my $div = $tree->find_one({ -tag => 'div' });
is($div->tag, 'div', "find found a div");
is($div, $tree, "it is the tree");

my $ul = $tree->find_one({ id => 'mylist' });
is($ul->tag, 'ul', "find found an ul");
is($ul->id, 'mylist', "it has the right id");
is($ul->parent, $div, "it has the right parent");
for (qw(menu foo)) {
  is($tree->find_one({ class => $_ }), $ul,
    "it can be found by class '$_'");
}
is($tree->find_one({ class => "menu foo" }), $ul,
  "it can be found by classes 'menu foo'");

for my $elem ($tree, $div, $ul) {
  for my $child ($elem->children) {
    is($child->parent, $elem, "child has parent");
  }
}

my $p = HTML::Element::Tiny->new([ p => "new node" ]);
is($p->parent, undef);
$tree->push($p);
is($p->parent, $tree, "did not clone element without parent");
$tree->push($p);
is($tree->find({ -tag => 'p' })->size, 2, "cloned element with parent");
$tree->push([ p => "new node 3" ]);
is($tree->find({ -tag => 'p' })->size, 3, "new elem from lol");
