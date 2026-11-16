# Jeewan Gamage, CV and résumé (R + Quarto)

One data file drives every document. Edit `data/cv.yml`, push, and GitHub
rebuilds the PDFs and Word files automatically into `output/`.

| Document | PDF | Word (editable) |
|---|---|---|
| Academic CV (long form) | `output/Jeewan_Gamage_cv-academic.pdf` | `output/Jeewan_Gamage_cv-academic.docx` |
| Industry résumé (2 to 3 pages) | `output/Jeewan_Gamage_resume-industry.pdf` | `output/Jeewan_Gamage_resume-industry.docx` |

## How to update

**On GitHub, no software needed.** Open `data/cv.yml`, click the pencil
icon, edit, and press *Commit changes*. The "Render CV" action runs for
about three minutes and the new files appear in `output/`.

**On your computer.** Install [R](https://cran.r-project.org), [RStudio](https://posit.co/download/rstudio-desktop/)
and [Quarto](https://quarto.org/docs/get-started/), then run
`Rscript render.R` or open a `.qmd` file in RStudio and click *Render*.
R packages needed: `yaml`, `glue`, `purrr`, `stringr`, `knitr`, `rmarkdown`.

## Files

- `data/cv.yml`: every fact (education, positions, publications, talks, awards, skills, references). This is the only file you normally edit.
- `R/cv_functions.R`: R functions that turn the data into CV sections (two-column entries, dated lists, publication formatting).
- `cv-academic.qmd`, `resume-industry.qmd`: the documents; each is a short list of section headings calling those functions.
- `cv-header.tex`: PDF styling in the spirit of the Awesome-CV template (fonts, colours, layout). Change the accent colour in the `awesome` line.
- `reference.docx`: Word styles for the `.docx` output, created automatically on first render. Open it in Word, change fonts or heading styles, save, and every Word export follows.
- Fonts: the PDF uses Lato and Roboto. GitHub downloads them during the build; on your own computer, install both from Google Fonts (or put the .ttf files in a `fonts/` folder).
- `images/photo.jpg`: add a square headshot with this name and it appears in the header automatically.

## Adding a publication

Append an entry under `publications:` in `data/cv.yml`:

```yaml
  - authors: "Gamage, J., Gillespie, A. W., Schneider, K."
    year: "2026"
    title: "Title of the paper"
    journal: "Journal name"
    volume: "12, 345"
    doi: "10.xxxx/xxxxx"
```

Your name is bolded automatically.
