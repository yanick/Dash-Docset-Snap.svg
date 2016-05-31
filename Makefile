docset:
	perl generate-docset.pl

tarball: docset
	cd build && tar -cvzf Snap.svg.tgz snap.svg.docset

contrib: tarball
	cp build/Snap.svg.tgz Dash-User-Contributions/docsets/Snap.svg/

