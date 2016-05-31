docset:
	perl generate-docset.pl

tarball: docset
	tar -cvzf build/Snap.svg.tgz build/snap.svg.docset

contrib: tarball
	cp build/snap.svg.tgz Dash-User-Contributions/docsets/Snap.svg/

