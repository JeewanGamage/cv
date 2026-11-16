# ---------------------------------------------------------------------------
# cv_functions.R
# Helper functions that turn data/cv.yml into Markdown sections.
# Every section of the CV and the résumé is rendered by one of these
# functions, so editing data/cv.yml is all that is needed to update both.
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(yaml)
  library(glue)
  library(purrr)
  library(stringr)
})

load_cv <- function(path = "data/cv.yml") {
  # read as UTF-8 explicitly so superscripts such as ¹³C survive on any locale
  txt <- readLines(path, encoding = "UTF-8", warn = FALSE)
  yaml::yaml.load(paste(enc2utf8(txt), collapse = "\n"))
}

# print markdown so knitr emits it as-is (chunks use results = "asis")
out <- function(...) cat(paste0(..., collapse = "\n"), "\n\n", sep = "")

is_pdf <- function() {
  fmt <- tryCatch(knitr::opts_knit$get("rmarkdown.pandoc.to"), error = function(e) NULL)
  !is.null(fmt) && grepl("latex|pdf", fmt)
}

# Escape LaTeX special characters in text that is emitted inside raw LaTeX
# commands (pandoc does not escape text that follows a raw \item line).
tex <- function(x) {
  if (!is_pdf()) return(x)
  x <- str_replace_all(x, "([&%$#_])", "\\\\\\1")
  x <- str_replace_all(x, "\\*\\*(.+?)\\*\\*", "\\\\textbf{\\1}")
  str_replace_all(x, "~", "\\\\textasciitilde{}")
}

# A two-column "entry" (left: dates, right: content). In PDF we use a LaTeX
# environment defined in cv-header.tex; in Word we fall back to a bold line.
entry <- function(when, title, subtitle = NULL, bullets = NULL, place = NULL) {
  if (is_pdf()) {
    sub <- if (!is.null(subtitle)) glue("\\newline \\cvsub{{{tex(subtitle)}}}") else ""
    plc <- if (!is.null(place)) glue(" \\cvplace{{{tex(place)}}}") else ""
    out(glue("\\cventry{{{when}}}{{\\cvtitle{{{tex(title)}}}{plc}{sub}}}"))
    if (length(bullets)) {
      out("\\begin{cvitems}")
      walk(bullets, ~ out(glue("\\item {tex(.x)}")))
      out("\\end{cvitems}")
    }
  } else {
    hdr <- glue("**{title}**")
    if (!is.null(place)) hdr <- glue("{hdr} ({place})")
    out(glue("{hdr}  "))
    if (!is.null(subtitle)) out(glue("*{subtitle}*  "))
    out(glue("{when}"))
    if (length(bullets)) walk(bullets, ~ out(glue("- {.x}")))
  }
}

# A simple "year | text" list used for awards, grants, talks, etc.
dated_list <- function(items, when = "year", text = "text") {
  if (is_pdf()) {
    out("\\begin{cvdated}")
    walk(items, ~ out(glue("\\item \\cvdate{{{tex(.x[[when]])}}} {tex(.x[[text]])}")))
    out("\\end{cvdated}")
  } else {
    walk(items, ~ out(glue("- **{.x[[when]]}** {.x[[text]]}")))
  }
}

bullet_list <- function(items, field = "text") {
  walk(items, ~ out(glue("- {if (is.list(.x)) .x[[field]] else .x}")))
}

numbered_list <- function(texts) {
  iwalk(texts, ~ out(glue("{.y}. {.x}")))
}

# Publication formatting: first-author Gamage/Kumara in bold
format_pub <- function(p, with_status = FALSE) {
  authors <- str_replace_all(p$authors, "(Gamage, J\\.|Kumara, H\\. G\\. J\\. T\\.)", "**\\1**")
  doi <- if (!is.null(p$doi) && nzchar(p$doi)) glue(" <https://doi.org/{p$doi}>") else ""
  vol <- if (!is.null(p$volume) && nzchar(p$volume)) glue(" {p$volume}.") else ""
  status <- if (with_status && !is.null(p$status)) glue(" [{p$status}]") else ""
  glue("{authors} ({p$year}). {p$title}. *{p$journal}*{vol}{doi}{status}")
}

education_section <- function(cv) {
  walk(cv$education, function(e) {
    entry(when = glue("{e$start} to {e$end}"), title = e$degree,
          subtitle = glue("{e$institution}, {e$place}"), bullets = list(e$detail))
  })
}

positions_section <- function(cv, keep = NULL) {
  pos <- cv$positions
  if (!is.null(keep)) pos <- keep(pos, ~ .x$title %in% keep)
  walk(pos, function(p) {
    entry(when = glue("{p$start} to {p$end}"), title = p$title,
          subtitle = p$org, place = p$place, bullets = p$bullets)
  })
}

skills_section <- function(cv) {
  if (is_pdf()) {
    out("\\begin{cvskills}")
    walk(cv$skills, ~ out(glue("\\item \\cvskill{{{tex(.x$group)}}} {tex(.x$items)}")))
    out("\\end{cvskills}")
  } else {
    walk(cv$skills, ~ out(glue("- **{.x$group}:** {.x$items}")))
  }
}

references_section <- function(cv) {
  walk(cv$references, ~ out(glue("**{.x$name}**, {.x$role}. {.x$contact}  ")))
}

counts <- function(cv) {
  list(pubs = length(cv$publications), review = length(cv$under_review),
       talks = length(cv$talks), posters = length(cv$posters))
}
