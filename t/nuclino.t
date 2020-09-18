#!/usr/bin/perl

use strict;
use warnings;

use Markdown::Table;
use Test::More;

my $markdown = q~
This table shows all employees and their role.

+---+---+---+
| Id | Name | Role |
+---+---+---+
| 1 | John Smith | Testrole |
+---+---+---+
| 2 | Jane Smith | Admin |
+---+---+---+

And this is a second table showing something different

+---+---+
| ID | Dists |
+---+---+
|  1 |   198 |
+---+---+
|  2 |    53 |
+---+---+
|  3 |    21 |
+---+---+
~;

my @tables = Markdown::Table->parse(
    $markdown,
    { nuclino => 1 },
);

is $tables[0]->get_table, '';
is $tables[1]->get_table, '';

done_testing();
