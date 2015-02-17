
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

MARKERS = 1 17 33 49 65 81 97 113 129 145 161 177 193 209 225

MARKER_ONE = 4/1, 1/2, 2/2, 5/2, 2/3, 4/3
MARKER_TWO = 2/1, 5/1, 2/2, 5/2, 2/3, 4/3

all: $(addprefix marker_,$(addsuffix .pdf,$(MARKERS)))

figures: $(addprefix figure_,$(addsuffix .pdf,$(MARKERS)))

marker_%.pdf:
	sed -e 's|@MARKER@|{$(MARKER_ONE), $(MARKER_$*)}|g' marker.tex > tmp_$*.tex
	pdflatex tmp_$*.tex
	mv tmp_$*.pdf $@
	rm tmp_$*.*

	sed -e 's|@MARKER@|{$(MARKER_TWO), $(MARKER_$*)}|g' marker.tex > tmp_$$(expr $* + 1).tex
	pdflatex tmp_$$(expr $* + 1).tex
	mv tmp_$$(expr $* + 1).pdf marker_$$(expr $* + 1).pdf
	rm tmp_$$(expr $* + 1).*

figure_%.pdf:
	sed -e 's|@MARKER@|{$(MARKER_ONE), $(MARKER_$*)}|g' figure.tex > tmp_$*.tex
	pdflatex tmp_$*.tex
	mv tmp_$*.pdf $@
	rm tmp_$*.*

	sed -e 's|@MARKER@|{$(MARKER_TWO), $(MARKER_$*)}|g' figure.tex > tmp_$$(expr $* + 1).tex
	pdflatex tmp_$$(expr $* + 1).tex
	mv tmp_$$(expr $* + 1).pdf figure_$$(expr $* + 1).pdf
	rm tmp_$$(expr $* + 1).*

clean:
	for f in $(foreach M,$(MARKERS),$M $(shell expr $M + 1)); do \
		rm -f marker_$$f.pdf; \
	done
