#!/Users/dbetz/.plenv/versions/5.34.1/bin/perl

use strict;
use warnings;

use Readonly qw(Readonly);
use LWP::UserAgent ();
use HTML5::DOM;

Readonly my $URL               => 'https://www.faa.gov/be-atc';
Readonly my $TEXT_MATCH        => 'The 2022 application window is now closed. Check back for future announcements!';
Readonly my $ATTEMPT_THRESHOLD => 6;
Readonly my $ATTEMPT_DELAY     => 10;

my $ua = LWP::UserAgent->new();

my $attempt_count = 0;
while ( ++$attempt_count < $ATTEMPT_THRESHOLD ) {
  my $response = $ua->get($URL);

  if ( $response->is_success() ) {
    my $parser = HTML5::DOM->new();
    my $tree = $parser->parse($response->content());

    my $node = $tree->querySelector('h4 > strong');
    if ( !$node || $node->text() ne $TEXT_MATCH ) {
      my $command = 'osascript -e \'display notification '
        . '"The Be ATC Page Changed!" '
        . 'with title "Be ATC Page Change!" '
        . 'sound name "default"\'';

      system $command;
    }

    last;
  }

  sleep $ATTEMPT_DELAY;
}

