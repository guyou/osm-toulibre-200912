# -*- makefile -*-

LATEX = TEXINPUTS=.:$(HOME)/text/tex/style: latex
PDFLATEX = TEXINPUTS=.:$(HOME)/text/tex/style: pdflatex
BIBTEX = BSTINPUTS=.:style: bibtex
LATEX2HTMLOPT = -local_icons -split +1 -address '<emarsden@laas.fr>' -info ""
LATEX2HTML = latex2html $(LATEX2HTMLOPT)

TEXFILES = $(strip $(wildcard *.tex))
TEXSTEMS = $(strip $(patsubst %.tex,%,${TEXFILES}))
PDFFILES = $(strip $(patsubst %.tex,%.pdf,${TEXFILES}))

SVGFIGURES = $(wildcard figures/*.svg)
FIGURES = $(SVGFIGURES:.svg=.pdf)

.SUFFIXES: .aux .bbl .tex .dvi .fig .dot .mp .ps .ps1 .eps .pdf .png .html .txt .svg $(.SUFFIXES)

generated = *.out *.mpx *.log *.aux *.blg *.bbl .depend



.tex.dvi: 
	$(LATEX) $<
	-grep 'Warning: .+undefined references' $*.log && $(LATEX) $<
	rm $*.log

.tex.aux:
	$(LATEX) $<

.aux.bbl: biblio.bib
	$(BIBTEX) $(basename $<)

.tex.html:
	$(LATEX2HTML) $<

.tex.pdf:
	$(PDFLATEX) $<
	-grep 'Warning: .+undefined references' $*.log && $(PDFLATEX) $<
	rm $*.log

.pdf.txt:
	pdftotext $<

.eps.pdf:
	epstopdf $<

.svg.eps:
	convert $< $@




all: osm-slides.pdf

osm-slides.pdf: $(TEXFILES) $(FIGURES)

clean:
	-rm -f ${generated}

.PHONY: clean

depend: .depend

.depend: Makefile ${TEXFILES}
	rm -f $@
	@for t in ${TEXSTEMS} ; do \
		echo "Scanning $$t.tex"; \
		mktexdep.pl $$t.pdf < $$t.tex >> $@; \
	done
