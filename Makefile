doc: docs/man/man1/git-cms-addpkg.1 docs/man/man1/git-cms-checkdeps.1 docs/man/man1/git-cms-merge-topic.1 docs/man/man1/git-cms-cvs-history.1

docs/man/man1/%.1: docs/man/%.1.in
	nroff -man $< > $@

.PHONY: doc
