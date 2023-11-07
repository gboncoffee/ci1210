LATEX = pdflatex --shell-escape

relatorio.pdf: relatorio.tex referencias.bib
	$(LATEX) relatorio.tex
	bibtex relatorio
	$(LATEX) relatorio.tex
	$(LATEX) relatorio.tex

clean:
	-rm relatorio.pdf
	-rm relatorio.aux
	-rm relatorio.out
	-rm relatorio.log
	-rm relatorio.blg
	-rm relatorio.bbl
	-rm -r svg-inkscape
