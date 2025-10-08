# Install & load required packages
pkgs <- c("tidyverse","janitor","readr","readxl","stringr","scales")
new  <- setdiff(pkgs, rownames(installed.packages()))
if(length(new)) install.packages(new, repos = "https://cloud.r-project.org")
invisible(lapply(pkgs, library, character.only = TRUE))

# Set unified theme
theme_set(theme_minimal(base_size = 12))
theme_update(panel.grid.minor = element_blank())
dir.create("plots", showWarnings = FALSE)

# Step 1: Auto-detect file paths in the current directory
path_yrbss <- Sys.glob("yrbss*.csv")[1]
path_gshs  <- Sys.glob("DASH*GSHS*csv")[1]
path_aihw  <- Sys.glob("aihw*physical*activity*xlsx")[1]

cat("Using files:\n",
    " - YRBSS:", path_yrbss, "\n",
    " - GSHS :", path_gshs,  "\n",
    " - AIHW :", path_aihw,  "\n")

# Safety check: Make sure files exist
stopifnot(file.exists(path_yrbss), file.exists(path_gshs), file.exists(path_aihw))

# Step 2: Load YRBSS data
yr_raw <- readr::read_csv(path_yrbss, show_col_types = FALSE) %>% janitor::clean_names()
cat("YRBSS columns:\n"); print(names(yr_raw))

# Try to guess key column names (they may vary slightly between versions)
pick <- function(df, patterns){
  m <- unique(unlist(lapply(patterns, function(p) grep(p, names(df), ignore.case = TRUE, value = TRUE))))
  if(length(m)) m[1] else NA_character_
}
col_sleep <- pick(yr_raw, c("school.*night.*sleep","hours_sleep","sleep.*hours"))
col_tv    <- pick(yr_raw, c("hours.*tv.*school.*day","hours_tv"))
col_other <- pick(yr_raw, c("hours.*computer.*school.*day","hours.*video|hours.*gaming"))
col_sex   <- pick(yr_raw, c("^sex$","gender"))
col_grade <- pick(yr_raw, c("^grade$"))

cat("Detected:\n",
    " sleep =", col_sleep, "\n",
    " tv    =", col_tv, "\n",
    " other =", col_other, "\n",
    " sex   =", col_sex, "\n",
    " grade =", col_grade, "\n")

# Preview sample values in detected columns (check if values are hour-based buckets)
yr_raw %>% select(all_of(na.omit(c(col_sleep,col_tv,col_other)))) %>% head(10)

# Search for other screen-related column names (e.g. games, video, screen)
grep_cols <- grep("computer|video|game|screen", names(yr_raw), 
                  ignore.case = TRUE, value = TRUE)
grep_cols

# Preview first few rows from candidate columns
yr_raw %>% select(any_of(grep_cols)) %>% head(10)

# Step 3
# =========================
# STEP 3 — Clean and visualize YRBSS
# Output PNG files to ./plots/
# =========================

# 1) Check if previous step data exists
if (!exists("yr_raw")) stop("Please complete STEP 2 first: load yr_raw.")
if (!exists("col_sleep") || !exists("col_tv"))
  stop("Please complete STEP 2 first: identify col_sleep and col_tv.")

dir.create("plots", showWarnings = FALSE)

# 2) Define conversion functions (handle text like 'do not watch' or '<5')
to_hours <- function(x){
  s <- tolower(as.character(x))
  dplyr::case_when(
    str_detect(s, "do not|did not|none|no .*use|no .*watch") ~ 0,
    str_detect(s, "10|10 or more") ~ 10,
    str_detect(s, "9") ~ 9,
    str_detect(s, "8") ~ 8,
    str_detect(s, "7") ~ 7,
    str_detect(s, "6") ~ 6,
    str_detect(s, "5\\+|5 or more") ~ 5,
    str_detect(s, "4") ~ 4,
    str_detect(s, "3") ~ 3,
    str_detect(s, "2") ~ 2,
    str_detect(s, "<1|less than 1|0") ~ 0.5,
    str_detect(s, "1") ~ 1,
    TRUE ~ suppressWarnings(as.numeric(s))
  )
}
sleep_to_hours <- function(x){
  s <- tolower(as.character(x))
  dplyr::case_when(
    str_detect(s, "^<\\s*5$") ~ 4.5,
    str_detect(s, "4 or less") ~ 4,
    str_detect(s, "10 or more") ~ 10,
    str_detect(s, "^(5|6|7|8|9)$") ~ as.numeric(s),
    TRUE ~ suppressWarnings(as.numeric(s))
  )
}

# 3) Construct analysis dataset (TV time used as total screen time if others missing)
yr <- yr_raw %>%
  mutate(
    sleep_h = sleep_to_hours(.data[[col_sleep]]),
    tv_h    = to_hours(.data[[col_tv]]),
    screen_h_total = tv_h,                          # fallback to TV if no other screen data
    sleep_lt8 = if_else(sleep_h < 8, 1, 0, missing = NA)
  ) %>%
  mutate(screen_bracket = cut(
    screen_h_total,
    breaks  = c(-Inf, 1, 2, 3, 4, 5, Inf),
    labels  = c("≤1","1–2","2–3","3–4","4–5","≥5"),
    right   = FALSE
  ))

# 4) Project color palette and theme (dashboard friendly)
sb_col <- list(
  text    = "#111827",  # near-black
  subtext = "#6B7280",  # gray-500
  grid    = "#E5E7EB",  # gray-200
  primary = "#3B82F6",  # blue-500
  accent  = "#10B981"   # emerald-500
)
theme_sleepbuddy <- function(base_size = 12){
  theme_minimal(base_size = base_size) %+replace%
    theme(
      plot.title       = element_text(face="bold", size=16, colour=sb_col$text),
      plot.subtitle    = element_text(size=11, colour=sb_col$subtext, margin=margin(b=6)),
      axis.title       = element_text(colour=sb_col$text),
      axis.text        = element_text(colour="#374151"),
      panel.grid.major = element_line(colour=sb_col$grid, linewidth=.4),
      panel.grid.minor = element_blank(),
      legend.position  = "top",
      legend.title     = element_text(face="bold")
    )
}

# 5) Plot 1: Bar plot — TV time brackets vs. % of students sleeping <8h
p1_data <- yr %>%
  drop_na(screen_bracket, sleep_lt8) %>%
  group_by(screen_bracket) %>%
  summarise(pct_lt8 = mean(sleep_lt8)*100, .groups="drop")

p1 <- ggplot(p1_data, aes(screen_bracket, pct_lt8)) +
  geom_col(fill = sb_col$primary, width = .6, alpha = .9) +
  geom_text(aes(label = scales::percent(pct_lt8/100, accuracy = 1)),
            vjust = -0.35, size = 3.6, colour = sb_col$text) +
  scale_y_continuous(
    labels = scales::label_percent(accuracy = 1, scale = 1/100),  # important: scale = 1/100
    limits = c(0, max(p1_data$pct_lt8)*1.15),
    expand = expansion(mult = c(0, .06))
  ) +
  labs(
    title    = "More TV time → more short sleepers (<8h)",
    subtitle = "Share of students sleeping <8h by TV time on school days (YRBSS)",
    x        = "TV time (hours per school day)",
    y        = "Students sleeping <8h"
  ) +
  theme_sleepbuddy()

ggsave("plots/yrbss_lt8_by_tv_pretty.png", p1,
       width = 9, height = 5.5, dpi = 200, bg = "transparent")

# 6) Plot 2: Heatmap + LOESS — TV time vs. sleep hours
p2 <- yr %>%
  drop_na(screen_h_total, sleep_h) %>%
  ggplot(aes(screen_h_total, sleep_h)) +
  geom_bin2d(bins = 24) +
  scale_fill_viridis_c(name = "Students", option = "C") +
  geom_smooth(method = "loess", se = TRUE, colour = sb_col$primary, linewidth = 1.2) +
  scale_x_continuous(breaks = 0:5, limits = c(0, 5.1)) +
  scale_y_continuous(breaks = 4:10, limits = c(4, 10.2)) +
  labs(
    title    = "Heavier TV use is linked with fewer sleep hours",
    subtitle = "Each tile shows student density; line shows LOESS trend (YRBSS)",
    x        = "TV hours (per school day)",
    y        = "Sleep hours (school nights)"
  ) +
  theme_sleepbuddy()

ggsave("plots/yrbss_tv_vs_sleep_heat_pretty.png", p2,
       width = 9, height = 5.5, dpi = 200, bg = "transparent")

# 7) (Optional) Plot 3: Faceted plots by sex
col_sex <- if (exists("col_sex") && !is.na(col_sex) && col_sex %in% names(yr_raw)) col_sex else NA
if (!is.na(col_sex)) {
  yr_sex <- yr %>% mutate(sex = factor(yr_raw[[col_sex]]))
  p2_sex <- yr_sex %>%
    drop_na(screen_h_total, sleep_h, sex) %>%
    ggplot(aes(screen_h_total, sleep_h)) +
    geom_bin2d(bins = 22) +
    scale_fill_viridis_c(name = "Students", option = "C") +
    geom_smooth(method = "loess", se = TRUE, colour = sb_col$accent, linewidth = 1.1) +
    facet_wrap(~ sex, nrow = 1) +
    scale_x_continuous(breaks = 0:5, limits = c(0, 5.1)) +
    scale_y_continuous(breaks = 4:10, limits = c(4, 10.2)) +
    labs(title = "TV hours vs. sleep hours (by sex)",
         x = "TV hours/day", y = "Sleep hours") +
    theme_sleepbuddy()
  
  ggsave("plots/yrbss_tv_vs_sleep_by_sex_pretty.png", p2_sex,
         width = 11, height = 5.3, dpi = 200, bg = "transparent")
}

cat("Done.\nSaved:\n - plots/yrbss_lt8_by_tv_pretty.png",
    "\n - plots/yrbss_tv_vs_sleep_heat_pretty.png",
    if (!is.na(col_sex)) "\n - plots/yrbss_tv_vs_sleep_by_sex_pretty.png" else "",
    "\n")
