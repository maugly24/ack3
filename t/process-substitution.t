#!perl

use strict;
use warnings;
use lib 't';

use Test::More;
use Util;

my @expected = (
    'THIS IS ALL IN UPPER CASE',
    'this is a word here',
);

prep_environment();

if ( is_windows() ) {
    plan skip_all => 'Test unreliable on Windows.';
}

system 'bash', '-c', 'exit';
if ( $? ) {
    plan skip_all => 'You need bash to run this test';
    exit;
}

plan tests => 1;

my ( $read, $write );

pipe( $read, $write );

my $pid = fork();

my @output;

if ( $pid ) {
    close $write;
    while ( <$read> ) {
        chomp;
        push @output, $_;
    }
    waitpid $pid, 0;
}
else {
    close $read;
    open STDOUT, '>&', $write or die "Can't open: $!";
    open STDERR, '>&', $write or die "Can't open: $!";

    my @args = adjust_executable( build_ack_invocation( qw( --noenv --nocolor --smart-case this ) ) );
    my $args = join( ' ', @args );
    exec 'bash', '-c', "$args <(cat t/swamp/options.pl)";
}

lists_match( \@output, \@expected, __FILE__ );

exit 0;
