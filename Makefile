TARGETS = rulebook

all: $(addsuffix .pdf, $(TARGETS))

%.pdf: %.tex
	latexmk -pdf $<

check: $(foreach curr_file,$(TARGETS), lint_$(curr_file) check-filetype_$(curr_file) check-trailing-whitespace_$(curr_file) check-line-length_$(curr_file))



.PHONY: markers
markers:
	(cd markers; make)
	cp markers/numbered_markers.pdf .
	cp markers/markers.pdf .

# warning numbers that chktex should ignore
chktex_ignore=24 44

# maximum allowed length of a line
linelength=80

lint_%: %.tex
	@chktex -n 12 -q $(foreach w,$(chktex_ignore),-n $w) $< | tee chktex.log
	@bash -c '\
		if [ -s chktex.log ] ; then \
			echo "ERROR(lint): chktex found errors"; \
			exit 1; \
		else \
			echo "lint: chktex passed!"; \
		fi'

check-filetype_%: %.tex
	@bash -c '\
		expected1="LaTeX 2e document, UTF-8 Unicode text"; \
		expected2="LaTeX 2e document, ASCII text"; \
		actual="$$(file -b $<)"; \
		if [[ "$$actual" != "$$expected1" && "$$actual" != "$$expected2" ]] ; then \
			echo "ERROR: Unexpected filetype"; \
			echo "Expected: $$expected1 or $$expected2"; \
			echo "Actual: $$actual"; \
			exit 1; \
		else \
			echo "check: filetype check passed!"; \
		fi'

check-trailing-whitespace_%: %.tex
	@bash -c '\
		trailing=$$(grep -n "\s$$" $<); \
		if [ $$? -eq 0 ] ; then \
			echo "Lines with trailing whitespace:"; \
			echo "$$trailing"; \
		  echo "ERROR: Found trailing whitespace"; \
			exit 1; \
		else \
			echo "check: no trailing whitespaces, check passed!"; \
		fi'

check-line-length_%: %.tex
	@bash -c '\
		longlines=$$(grep -n -e "^..\{${linelength}\}" $< | grep -v -e "ignore-long-line" -e "^[0-9]*:\%"); \
		if [ $$? -eq 0 ] ; then \
			echo "Lines with length > ${linelength}:"; \
			echo "$$longlines"; \
			echo "ERROR: Found lines exceeding the max line length ${linelength}:"; \
			exit 1; \
		else \
			echo "check: no overlong lines found, check passed!"; \
		fi'
