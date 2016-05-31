#!/usr/bin/perl 

use 5.20.0;

use strict;
use warnings;

use Dash::Docset::Generator;
use Text::MultiMarkdown qw/ markdown /;
use Path::Tiny;
use Web::Query::LibXML;
use List::Util qw/ pairs pairmap /;

my $docset = Dash::Docset::Generator->new( 
    name => "Snap.svg",
    platform_family => 'snapsvg',
    output_dir => 'docset',
    homepage => 'http://snapsvg.io',
);

my $index = wq( 'reference.html' );
$index->find('base,#sideNav')->remove;
$index->find('head')->append(<<'END');
<style>
@media screen and ( min-width: 650px ) {
  #content {
    padding-left: 20px;
  }
}
#header .logo img { width: inherit; }
</style>
END
$index->find('link')->each(sub{
    $_->attr('href', $_->attr('href') =~ s#docs/##r );
    $_->attr('href', $_->attr('href') =~ s#^/##r );
    $_->attr('href', $_->attr('href') =~ s#\?.*$##r );
});
$index->find('script')->filter(sub{
        $_->as_html =~ /google/;
})->remove;

$index->find('img')->each(sub{
        $_->attr('src', $_->attr('src') =~ s/\.svg/\.png/r =~ s#^/##r );
});

$index->find('nav a')->each(sub{
        $_->attr('href', 'http://snapsvg.io'.$_->attr('href') );
});

my $master_clone = $index->clone;

$index->find( 'head' )->append(<<'END');
<style>
    @media screen and (max-width: 750px) {
        #header nav { display: block; }
    }
    #header nav a { display: block; }
    #header nav { float: none; }
    #header .logo { float:none; display: block; margin-bottom: 20px; }
</style>
END

my %files;
$index->find('article')->each(sub{
        my $thing = $_->attr('id');

        my( $class ) = $thing =~ /[^.]+/g;
        warn "processing $class...\n";
        my $file = $class.'.html';

        unless( $files{$file} ) {
            my $doc = $master_clone->clone;
            $doc->find('#content')->html("<h2><a docset-type='Class' docset-name='$class'>$class</a>"
                . "<a class='dashAnchor' name='//apple_ref/cpp/Class/$class'></a></h2>");
            $files{$file} = $doc;
        }

        my $doc = $files{$file};

        my $type = $thing =~ /\./ ? 'Method' : 'Constructor';

        $_->find( 'header h3 a' )->first->attr( 'docset-type' => $type );
        $_->find( 'header h3 a' )->first->attr( 'docset-name' => $thing );
        $_->find( 'header h3 a' )->first->attr( 'name' => $thing );
        $_->find( 'header h3 a' )->first->after( "<a class='dashAnchor' name='//apple_ref/cpp/$type/$thing'></a>" );

        $doc->find('#content')->append($_);
        $_->remove;
});

pairmap { $docset->add_doc( $a => $b ) } %files;
$docset->add_doc( 'index.html' => $index );

path('assets')->visit(sub{
        my $path = shift;
        return if $path->is_dir;
        $docset->add_asset( { $path => $path->relative('assets') } );
}, { recurse => 1 });

$docset->add_asset( path('css')->children,  
    path('js')->children );

$docset->icon('assets/images/icon.png');

$docset->generate;

sub new_doc {
    wq( '<html><head/><body/></html>' );
}

