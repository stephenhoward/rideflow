package Javascript::Compile;

use strict;
use warnings;

use JavaScript::Minifier::XS 'minify';
use Path::Tiny;
use List::Util 'first';

use base 'Exporter';

our @EXPORT_OK = qw( compile_js );

sub compile_js {
    my ( $src, $dest, $no_minify ) = @_;

    $src = [ $src ] unless ( ref( $src ) || '') eq 'ARRAY';

    my %paths = (
        bin      => [ map { path( $_, '/bin' ) } grep { $_ ne $dest } @$src ],
        lib      => [ map { path( $_, '/lib' ) } @$src ],
        compiled => path( $dest )
    );

    $paths{compiled}->mkpath if ! $paths{compiled}->exists;

    foreach my $bin ( @{$paths{bin}} ) {

        $paths{current_bin} = $bin;

        my $iterator = $bin->iterator({
            recurse => 1,
            follow_symlinks => 0,
        });

        while ( my $path = $iterator->() ) {
            if ( $path->is_file && $path->basename =~ /\.js$/ ) {
                compile_script( $path, \%paths, $no_minify );
            }
        }

    }
}

sub compile_script {
    my ( $path, $paths, $no_minify ) = @_;
    my %files_seen;

    my $file_string = include_script( $path, $paths, \%files_seen );
    my $relpath     = $paths->{compiled}->child( $path->relative( $paths->{current_bin} ) );

    $relpath->parent->mkpath if ! $relpath->parent->exists;
    $relpath->spew( $no_minify ? $file_string : minify($file_string) );
}

sub include_script {
    my ( $path, $paths, $files_seen ) = @_;

    $files_seen->{$path->stringify}++;

    my @includes;
    my @lines = $path->lines;

    foreach my $line ( @lines ) {

        if( $line =~ m{ ^   # on its own line
            \s* /\*         # open js block comment
            \s* include     # "include" directive
            \s+ ([^\s]*)    # filename
            \s+ \*/         # close js block comment
            \s* $           # end of line
        }x ) {
            my $include = first { $_->exists } map { $_->child($1) } @{$paths->{lib}};
            if ( ! defined $files_seen->{ $include->stringify } ) {
                push @includes, include_script( $include, $paths, $files_seen );
            }
        }
    }
    return join "\n", @includes, @lines;
}

1;
