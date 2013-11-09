use strict;
use warnings;
use 5.012;
use autodie;

use Template;
use DateTime;
my $tt = Template->new({
	INCLUDE_PATH => 'tt',
	START_TAG    => '<%',
	END_TAG      => '%>',
	EVAL_PERL    => 0,
});
my $now = DateTime->now->ymd;

my @pages = map { substr $_, 6 } glob "pages/*.html";
#print "@pages";

my $sitemap = qq{<?xml version="1.0" encoding="UTF-8"?>\n};
$sitemap .=   qq{<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n};


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
	$sitemap .= qq{  <url>\n};
	$sitemap .= qq{    <loc>http://dwimperl.com/$p</loc>\n};
	$sitemap .= qq{    <lastmod>$now</lastmod>\n};
	$sitemap .= qq{  </url>\n};
}

$sitemap .= "</urlset>\n";

if (open my $out, '>', 'html/sitemap.xml') {
	print $out $sitemap;
}


