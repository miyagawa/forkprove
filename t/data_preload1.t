#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use lib '.';
use t::UsesData;

is(t::UsesData->get_data, "abc\n");
is(t::UsesData->get_data, "abc\n");

done_testing;
