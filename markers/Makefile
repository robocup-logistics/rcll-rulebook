MARKERS = 101 103 201 203 111 113 211 213 121 221 131 231 141 241 301

all: numbered_markers.pdf markers.pdf

numbered_markers.pdf: $(addprefix numbered_marker_,$(addsuffix .pdf,$(MARKERS)))
	$(eval NUM_MARKERS := $(words $(MARKERS)))
	pdfunite $(foreach M,$(MARKERS),numbered_marker_$M.pdf $(if $(filter $(M),301),,$(if $(filter $(M),$(lastword $(MARKERS))),,$(space)numbered_marker_$(shell expr $M + 1).pdf ))) numbered_markers.pdf

markers.pdf: $(addprefix marker_,$(addsuffix .pdf,$(MARKERS)))
	$(eval NUM_MARKERS := $(words $(MARKERS)))
	pdfunite $(foreach M,$(MARKERS),marker_$M.pdf $(if $(filter $(M),301),,$(if $(filter $(M),$(lastword $(MARKERS))),,$(space)marker_$(shell expr $M + 1).pdf ))) markers.pdf

marker_%.pdf:
	sed -e 's|@ID@|$*|g' marker.tex > tmp_$*.tex
	latexmk -pdf tmp_$*.tex
	mv tmp_$*.pdf $@
	rm tmp_$*.*
	if [ $* -ne 301 ]; then \
		sed -e 's|@ID@|$*|g' marker.tex > tmp_$$(expr $* + 1).tex; \
		latexmk -pdf tmp_$$(expr $* + 1).tex; \
		mv tmp_$$(expr $* + 1).pdf marker_$$(expr $* + 1).pdf; \
		rm tmp_$$(expr $* + 1).* ; \
	fi

numbered_marker_%.pdf: | marker_%.pdf
	sed -e 's|@ID@|$*|g' marker.tex > tmp_$*.tex
	latexmk -pdf tmp_$*.tex
	mv tmp_$*.pdf $@
	rm tmp_$*.*
	if [ $* -ne 301 ]; then \
		sed -e 's|@ID@|$(shell expr $* + 1)|g' marker.tex > tmp_$$(expr $* + 1).tex ; \
		latexmk -pdf tmp_$$(expr $* + 1).tex ; \
		mv tmp_$$(expr $* + 1).pdf numbered_marker_$$(expr $* + 1).pdf ; \
		rm tmp_$$(expr $* + 1).* ; \
	fi

clean:
	for f in $(foreach M,$(MARKERS),$M $(shell expr $M + 1)); do \
		rm -f marker_$$f.pdf; \
		rm -f numbered_marker_$$f.pdf; \
	done
	rm -f markers.pdf
	rm -f numbered_markers.pdf
