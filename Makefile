doc: docs/man/man1/git-cms-addpkg.1 docs/man/man1/git-cms-checkdeps.1 docs/man/man1/git-cms-merge-topic.1 docs/man/man1/git-cms-cvs-history.1 docs/man/man1/git-cms-showtags.1 docs/man/man1/git-cms-checkout-topic.1 docs/man/man1/git-cms-rebase-topic.1 docs/man/man1/git-cms-rmpkg.1

docs/man/man1/%.1: docs/man/%.1.in
	mkdir -p $(@D)
	nroff -man $< > $@

.PHONY: doc
