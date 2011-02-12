#!/usr/bin/perl

use strict; use warnings;

use Test::More;

plan tests => 4;

pass("Case 1");
pass("Case 2");

die("I die here");

pass("Third case");
pass("Last (fourth) case");

