# Render every CV variant to PDF and Word and copy the results into output/.
# Run with:  Rscript render.R      (or click "Render" in RStudio on any .qmd)
Sys.setlocale("LC_ALL", "C.UTF-8")
# Word styles template: created on first run if missing (edit it in Word to restyle)
if (!file.exists("reference.docx")) {
  system2("quarto", c("pandoc", "-o", "reference.docx", "--print-default-data-file", "reference.docx"))
}
dir.create("output", showWarnings = FALSE)
docs <- c("cv-academic", "resume-industry")
for (d in docs) {
  for (fmt in c("pdf", "docx")) {
    system2("quarto", c("render", paste0(d, ".qmd"), "--to", fmt))
    file.copy(paste0(d, ".", fmt), file.path("output", paste0("Jeewan_Gamage_", d, ".", fmt)), overwrite = TRUE)
  }
}
unlink(paste0(docs, ".pdf")); unlink(paste0(docs, ".docx"))
cat("Rendered:", list.files("output"), sep = "\n")
