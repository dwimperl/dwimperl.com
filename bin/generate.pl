use strict;
use warnings;
use 5.012;
use autodie;

use Template;
my $tt = Template->new({
	INCLUDE_PATH => 'tt',
	START_TAG    => '<%',
	END_TAG      => '%>',
	EVAL_PERL    => 0,
});

my @pages = map { substr $_, 6 } glob "pages/*.html";
#print "@pages";

foreach my $p (@pages) {
	open my $fh, '<', "pages/$p";
	my %params = ( content => '' );
	while (my $row = <$fh>) {
		#chomp $row;
		if ($row =~ /^=(\w+)\s*(.*)/) {
			$params{$1} = $2;
		} else {
			$params{content} .= $row;
		}
	}
	close $fh;

	$params{subtitle} ||= $params{title};

	for my $os (qw(windows linux history legal)) {
		if ($p eq "$os.html") {
			$params{$os} = 1;
		}
	}
	$tt->process('page.tt', \%params, "html/$p") or die $tt->error;
}
