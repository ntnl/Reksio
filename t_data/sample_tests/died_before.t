#!/usr/bin/perl

use strict; use warnings;

use Test::More;

die("I die here");

plan tests => 4;

pass("Case 1");
pass("Case 2");
pass("Third case");
pass("Last (fourth) case");

