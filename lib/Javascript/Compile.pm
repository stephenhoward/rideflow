package Javascript::Compile;

use strict;
use warnings;

use JavaScript::Minifier::XS 'minify';
use Path::Tiny;

use base 'Exporter';

our @EXPORT_OK = qw( compile_js );

sub compile_js {
    my ( $src, $dest, $no_minify ) = @_;

    my %paths = (
        bin      => path( $src, '/bin' ),
        lib      => path( $src, '/lib' ),
        compiled => path( $dest )
    );

    $paths{compiled}->mkpath if ! $paths{compiled}->exists;

    my $iterator = $paths{bin}->iterator({
        recurse => 1,
        follow_symlinks => 0,
    });

    while ( my $path = $iterator->() ) {
        if ( $path->is_file && $path->basename =~ /\.js$/ ) {
            compile_script( $path, \%paths, $no_minify );
        }
    }
}

sub compile_script {
    my ( $path, $paths, $no_minify ) = @_;
    my %files_seen;

    my $file_string = include_script( $path, $paths, \%files_seen );
    my $relpath     = $paths->{compiled}->child( $path->relative( $paths->{bin} ) );

    $relpath->parent->mkpath if ! $relpath->parent->exists;
    $relpath->spew( $no_minify ? $file_string : minify($file_string) );
}

sub include_script {
    my ( $path, $paths, $files_seen ) = @_;

    $files_seen->{$path->stringify}++;

    my @includes;
    my @lines = $path->lines;

warn "processing ".$path->stringify."\n";
    foreach my $line ( @lines ) {

        if( $line =~ m{ ^   # on its own line
            \s* /\*         # open js block comment
            \s* include     # "include" directive
            \s+ ([^\s]*)    # filename
            \s+ \*/         # close js block comment
            \s* $           # end of line
        }x ) {
            my $include = $paths->{lib}->child($1);
            if ( ! defined $files_seen->{ $include->stringify } ) {
                push @includes, include_script( $include, $paths, $files_seen );
            }
        }
    }
    return join "\n", @includes, @lines;
}

1;
