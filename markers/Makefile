
# Which blocks are black inside the tag
MARKER_1   = 3/4, 3/5
MARKER_17  = 3/4, 4/4, 1/5, 2/5, 3/5, 5/5
MARKER_33  = 2/4, 3/4, 5/4, 2/5, 3/5, 5/5
MARKER_49  = 2/4, 3/4, 4/4, 5/4, 1/5, 3/5
MARKER_65  = 1/4, 3/4, 5/4, 1/5, 3/5, 5/5
MARKER_81  = 1/4, 3/4, 4/4, 5/4, 2/5, 3/5
MARKER_97  = 1/4, 2/4, 3/4, 1/5, 2/5, 3/5
MARKER_113 = 1/4, 2/4, 3/4, 4/4, 4/5, 5/5
MARKER_129 = 3/4, 5/4, 1/5, 2/5, 3/5, 4/5
MARKER_145 = 3/4, 4/4, 5/4, 3/5, 4/5, 5/5
MARKER_161 = 2/4, 3/4, 1/5, 3/5, 4/5, 5/5
MARKER_177 = 2/4, 3/4, 4/4, 2/5, 3/5, 4/5
MARKER_193 = 1/4, 3/4, 2/5, 3/5, 4/5, 5/5
MARKER_209 = 1/4, 3/4, 4/4, 1/5, 3/5, 4/5
MARKER_225 = 1/3, 2/4, 3/4, 5/4, 3/5, 4/5

MARKERS = 1 2 17 18 33 34 177 178 65 66 81 82 193 194 97 98 113 114 129 130 145 146 161 162 49 50 209 210
MARKER_ONE = 4/1, 1/2, 2/2, 5/2, 2/3, 4/3
MARKER_TWO = 2/1, 5/1, 2/2, 5/2, 2/3, 4/3

all: numbered_markers.pdf markers.pdf

numbered_markers.pdf: $(addprefix numbered_marker_,$(addsuffix .pdf,$(MARKERS)))
	pdfunite $(foreach M,$(MARKERS),numbered_marker_$M.pdf ) numbered_markers.pdf

figures: $(addprefix figure_,$(addsuffix .pdf,$(MARKERS)))

markers.pdf: $(addprefix marker_,$(addsuffix .pdf,$(MARKERS)))
	pdfunite $(foreach M,$(MARKERS),marker_$M.pdf ) markers.pdf

marker_%.pdf:
	sed -e 's|@MARKER@|{$(MARKER_ONE), $(MARKER_$*)}|g' -e 's|@ID@||g' marker.tex > tmp_$*.tex
	latexmk -pdf tmp_$*.tex
	mv tmp_$*.pdf $@
	rm tmp_$*.*

	sed -e 's|@MARKER@|{$(MARKER_TWO), $(MARKER_$*)}|g' -e 's|@ID@||g' marker.tex > tmp_$$(expr $* + 1).tex
	latexmk -pdf tmp_$$(expr $* + 1).tex
	mv tmp_$$(expr $* + 1).pdf marker_$$(expr $* + 1).pdf
	rm tmp_$$(expr $* + 1).*

numbered_marker_%.pdf:
	sed -e 's|@MARKER@|{$(MARKER_ONE), $(MARKER_$*)}|g' -e 's|@ID@|$*|g' marker.tex > tmp_$*.tex
	latexmk -pdf tmp_$*.tex
	mv tmp_$*.pdf $@
	rm tmp_$*.*

	sed -e 's|@MARKER@|{$(MARKER_TWO), $(MARKER_$*)}|g' -e 's|@ID@|$(shell expr $* + 1)|g' marker.tex > tmp_$$(expr $* + 1).tex
	latexmk -pdf tmp_$$(expr $* + 1).tex
	mv tmp_$$(expr $* + 1).pdf numbered_marker_$$(expr $* + 1).pdf
	rm tmp_$$(expr $* + 1).*

figure_%.pdf:
	sed -e 's|@MARKER@|{$(MARKER_ONE), $(MARKER_$*)}|g' figure.tex > tmp_$*.tex
	latexmk -pdf tmp_$*.tex
	mv tmp_$*.pdf $@
	rm tmp_$*.*

	sed -e 's|@MARKER@|{$(MARKER_TWO), $(MARKER_$*)}|g' figure.tex > tmp_$$(expr $* + 1).tex
	latexmk -pdf tmp_$$(expr $* + 1).tex
	mv tmp_$$(expr $* + 1).pdf figure_$$(expr $* + 1).pdf
	rm tmp_$$(expr $* + 1).*

clean:
	for f in $(foreach M,$(MARKERS),$M $(shell expr $M + 1)); do \
		rm -f marker_$$f.pdf; \
		rm -f numbered_marker_$$f.pdf; \
	done
	rm markers.pdf
	rm numbered_markers.pdf
