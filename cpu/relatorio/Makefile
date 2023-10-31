relatorio.pdf: relatorio.tex referencias.bib
	pdflatex relatorio.tex
	bibtex relatorio
	pdflatex relatorio.tex
	pdflatex relatorio.tex

clean:
	-rm relatorio.pdf
	-rm relatorio.aux
	-rm relatorio.out
	-rm relatorio.log
