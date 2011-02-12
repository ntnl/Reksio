#!/usr/bin/perl

use strict; use warnings;

use Test::More;

plan tests => 8;

pass("Case 1");
fail("Case 2");
pass("Third case");
fail("Case 4");
fail("Case 5");
fail("Case six");
pass("Eight case");
pass("Last (eight) case");

