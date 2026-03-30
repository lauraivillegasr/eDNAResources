## 0. Setup ----
# Install once if needed
# install.packages(c("readr", "dplyr", "ggplot2"))

library(readr)
library(dplyr)
library(ggplot2)

## 1. Load GelGenie export ----
# Change this to your file path
df <- read_csv("gelgenie_export.csv")

# Expect at least: Name, Lane ID, Band ID, `Raw Volume`
# If your column names differ, adjust them here:
df <- df %>%
  rename(
    lane_id    = `Lane ID`,
    band_id    = `Band ID`,
    raw_volume = `Raw Volume`
  )

## 2. Annotate ladder bands and known masses ----
# Example: ladder in lane 5, with manufacturer ng per band:
# Replace with your actual ladder lane and masses.
ladder_info <- tribble(
  ~lane_id, ~band_id, ~mass_ng,
  5,        1,        50,   # e.g. 50 ng band
  5,        2,        40,
  5,        3,        30
  # add more rows as needed
)

# Join ladder info into the main table
df <- df %>%
  left_join(ladder_info,
            by = c("lane_id", "band_id"))

# Ladder rows are those with non-NA mass_ng
df_ladder <- df %>% filter(!is.na(mass_ng))

if (nrow(df_ladder) < 2) {
  stop("Need at least 2 ladder bands with known mass_ng for calibration.")
}

## 3. Fit calibration model (intensity -> mass) ----
# Start with simple linear model: mass_ng ~ raw_volume
fit <- lm(mass_ng ~ raw_volume, data = df_ladder)

summary(fit)   # optional: inspect fit quality

# Optionally plot calibration
ggplot(df_ladder, aes(x = raw_volume, y = mass_ng)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(x = "Raw volume (GelGenie)", y = "Mass (ng)")

## 4. Predict mass for all bands ----
df <- df %>%
  mutate(
    mass_ng = predict(fit, newdata = df)
  )

## 5. Convert to concentration (ng/µl) ----
# You can either set a single volume for all bands:
volume_loaded_ul <- 5  # CHANGE: µl loaded per lane

df <- df %>%
  mutate(
    conc_ng_ul = mass_ng / volume_loaded_ul
  )

# Or, if different volumes per lane, create a lookup:
# volume_info <- tribble(
#   ~lane_id, ~volume_loaded_ul,
#   1,        5,
#   2,        3,
#   3,        2,
#   4,        5,
#   5,        5,
#   6,        5
# )
#
# df <- df %>%
#   left_join(volume_info, by = "lane_id") %>%
#   mutate(conc_ng_ul = mass_ng / volume_loaded_ul)

## 6. Save results ----
write_csv(df, "gelgenie_with_concentration.csv")
