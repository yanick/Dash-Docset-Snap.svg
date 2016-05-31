docset:
	perl generate-docset.pl

tarball: docset
	tar -cvzf build/snap.svg.tgz build/snap.svg.docset

contrib: tarball
	cp build/snap.svg.tgz Dash-User-Contributions/docsets/Snap.svg/

