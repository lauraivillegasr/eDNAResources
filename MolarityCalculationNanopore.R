############################################################
## Nanopore amplicon pooling helper (R)
## - Designed for 4 markers (12S, Placo-16S, 28S, COI), more can be added, only name and length required
## - Works with ANY number of barcodes/locations
## - You will manually enter your Qubit concentrations ideally, for the smapling trip we will do estimations based on the gel
############################################################

## Load packages ------------------------------------------------------------
## install.packages(c("dplyr","tidyr","readr"))  # run once if needed
library(dplyr)
library(tidyr)
library(readr)

############################################################
## 1. Define markers and fragment lengths
############################################################

## Edit if you change markers or fragment sizes
markers <- tribble(
  ~Marker,        ~Fragment_bp, ~Target_taxon,
  "12S_coral",          180,     "Scleractinia",
  "Placo16S",           450,     "Placozoa",
  "D2_28S",             450,     "Sponges",
  "COI_folm",           710,     "COTS"
)

print(markers)

############################################################
## 2. Define how many barcodes/locations you will use
############################################################

## >>> THIS IS WHERE YOU CONTROL NUMBER OF LOCATIONS <<<
## Set n_barcodes to any value ≤ the kit capacity (e.g. 24 for NBD114.24)

n_barcodes <- 1   # change to actual number of locations you will multiplex

barcodes <- tibble(
  Barcode  = sprintf("BC%02d", 1:n_barcodes),
  Location = sprintf("Site_%02d", 1:n_barcodes)
)

print(barcodes)

############################################################
## 3. Create an INPUT TEMPLATE for your concentrations
############################################################

## One row per (Barcode × Marker).
## You will fill in the concentration (Conc_ng_ul) after Qubit measurements.

template <- barcodes %>%
  crossing(markers) %>%
  mutate(
    Conc_ng_ul = NA_real_   # <-- you will fill this in manually later
  )

## Write blank template to CSV
write_csv(template, "pooling_input_blank.csv")

message("\nSTEP 1 (in Excel or similar):")
message("  - Open 'pooling_input_blank.csv'")
message("  - For EACH row, enter your measured concentration in the 'Conc_ng_ul' column")
message("  - Save the file as 'pooling_input_filled.csv' in the same folder\n")

############################################################
## 4. READ YOUR FILLED CONCENTRATION FILE
############################################################

## >>> THIS IS WHERE YOUR CONCENTRATIONS ENTER THE SCRIPT <<<
## After you have filled 'pooling_input_blank.csv', uncomment:

#df <- read_csv("pooling_input_filled.csv")

## For now, df <- template is a placeholder so the script parses.
## Remove the next line once you use real data.
df <- template  # placeholder; REPLACE with the read_csv() line above

############################################################
## 5. Helper function: convert ng/µL + bp to nM
############################################################

## Formula:
##   Molarity (nM) = conc_ng_ul / (fragment_bp * 650) * 1e6
## where 650 g/mol is the average molecular weight of one dsDNA bp

calc_molarity <- function(conc_ng_ul, fragment_bp) {
  conc_ng_ul / (fragment_bp * 650) * 1e6
}

############################################################
## 6. Choose target volume per marker within each barcode
############################################################

## Example: 5 µL of each marker in the equimolar pool
## (gives 5 µL × 4 markers = 20 µL total amplicon volume per barcode)

target_vol_marker_ul <- 5

############################################################
## 7. Calculate molarity and pooling volumes
############################################################

## NOTE: when you switch to real data, df must come from read_csv()
## and must have valid numeric values in Conc_ng_ul.

df_pooled <- df %>%
  mutate(
    Molarity_nM = calc_molarity(Conc_ng_ul, Fragment_bp)
  ) %>%
  group_by(Barcode) %>%
  ## Within each barcode (location), find the lowest molarity.
  ## We dilute higher‑molarity amplicons down to this value.
  mutate(
    target_molarity_nM = min(Molarity_nM, na.rm = TRUE),
    Vol_ul   = target_molarity_nM / Molarity_nM * target_vol_marker_ul,
    Vol_ul   = round(Vol_ul, 2),
    Water_ul = round(target_vol_marker_ul - Vol_ul, 2)
  ) %>%
  ungroup()

## Inspect first few rows (check that volumes look reasonable)
print(head(df_pooled, 12))

## Save pooling plan
write_csv(df_pooled, "pooling_plan_equimolar.csv")
message("\nWrote 'pooling_plan_equimolar.csv' with pipetting volumes:")
message("  - Vol_ul  = µL of each amplicon to add to the barcode‑specific pool")
message("  - Water_ul = µL of water to bring each to ", target_vol_marker_ul, " µL total\n")

############################################################
## 8. Optional: simple read‑depth estimate
############################################################

## Choose a plausible read yield for your flow cell (adjust as needed)
total_reads_expected <- 6e6  # e.g. 6 million reads

reads_per_barcode <- total_reads_expected / n_barcodes
reads_per_marker  <- reads_per_barcode / n_distinct(df_pooled$Marker)

cat("Expected reads assuming perfect equimolar pooling:\n")
cat("  Total reads:         ", total_reads_expected, "\n")
cat("  Reads per barcode:   ", round(reads_per_barcode), "\n")
cat("  Reads per marker:    ", round(reads_per_marker), "\n\n")
cat("Shorter amplicons (e.g. 12S) may end up slightly over‑represented;\n",
    "you can tweak input ratios in future runs based on empirical results.\n")

############################################################
## END OF SCRIPT
############################################################
