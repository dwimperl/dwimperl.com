use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd qw(abs_path);

use Plack::App::Directory;
Plack::App::Directory->new(root => dirname(abs_path($0)) . '/html')
