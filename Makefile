pdf:
	latexmk -pdf rulebook.tex

check: lint check-filetype check-trailing-whitespace

lint:
	@chktex rulebook.tex | tee chktex.log
	@bash -c '\
		if [ -s chktex.log ] ; then \
			echo "ERROR(lint): chktex found errors"; \
			exit 1; \
		fi'

check-filetype:
	@bash -c '\
		expected="LaTeX 2e document, UTF-8 Unicode text"; \
		actual="$$(file -b rulebook.tex)"; \
		if [ "$$actual" != "$$expected" ] ; then \
			echo "Unexpected filetype"; \
			echo "Expected: $$expected"; \
			echo "Actual: $$actual"; \
		fi'

check-trailing-whitespace:
	@bash -c '\
		trailing=$$(grep -n "\s$$" rulebook.tex); \
		if [ $$? -eq 0 ] ; then \
			echo "Found trailing whitespace:"; \
			echo "$$trailing"; \
			exit 1; \
		fi'
