pdf:
	latexmk -pdf rulebook.tex

check: lint check-filetype check-trailing-whitespace check-line-length

# warning numbers that chktex should ignore
chktex_ignore=24 44

# maximum allowed length of a line
linelength=80

lint:
	@chktex -q $(foreach w,$(chktex_ignore),-n $w) rulebook.tex | tee chktex.log
	@bash -c '\
		if [ -s chktex.log ] ; then \
			echo "ERROR(lint): chktex found errors"; \
			exit 1; \
		else \
			echo "lint: chktex passed!"; \
		fi'

check-filetype:
	@bash -c '\
		expected="LaTeX 2e document, UTF-8 Unicode text"; \
		actual="$$(file -b rulebook.tex)"; \
		if [ "$$actual" != "$$expected" ] ; then \
			echo "ERROR: Unexpected filetype"; \
			echo "Expected: $$expected"; \
			echo "Actual: $$actual"; \
			exit 1; \
		else \
			echo "check: filetype check passed!"; \
		fi'

check-trailing-whitespace:
	@bash -c '\
		trailing=$$(grep -n "\s$$" rulebook.tex); \
		if [ $$? -eq 0 ] ; then \
			echo "Lines with trailing whitespace:"; \
			echo "$$trailing"; \
		  echo "ERROR: Found trailing whitespace"; \
			exit 1; \
		else \
			echo "check: no trailing whitespaces, check passed!"; \
		fi'

check-line-length:
	@bash -c '\
		longlines=$$(grep -n "^..\{${linelength}\}" rulebook.tex); \
		if [ $$? -eq 0 ] ; then \
			echo "Lines with length > ${linelength}:"; \
			echo "$$longlines"; \
			echo "ERROR: Found lines exceeding the max line length ${linelength}:"; \
			exit 1; \
		else \
			echo "check: no overlong lines found, check passed!"; \
		fi'
