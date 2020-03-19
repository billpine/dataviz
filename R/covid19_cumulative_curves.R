library(tidyverse)
library(ggpmthemes)
library(ggtext)

theme_set(theme_exo())

df <-
  read_csv(
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"
  )

df <- df %>%
  pivot_longer(-c(1:4), names_to = "date", values_to = "case_confirmed") %>%
  janitor::clean_names() %>%
  mutate(date = as.Date(date, "%m/%d/%y"))

df

df %>%
  count(country_region, sort = TRUE)

range(df$date)

total_case_confirmed <- df %>%
  filter(country_region %in% c("Canada", "US", "Italy", "China", "Spain")) %>%
  group_by(country_region, date) %>%
  summarise(total_case_confirmed = sum(case_confirmed)) %>%
  ungroup()

total_case_confirmed <- total_case_confirmed %>%
  group_by(country_region) %>%
  filter(total_case_confirmed >= 100) %>%
  mutate(day = date - min(date)) %>%
  mutate(day = as.integer(day))

lab <- total_case_confirmed %>%
  filter(day == max(day))


# Plot --------------------------------------------------------------------

total_case_confirmed %>%
  ggplot(aes(x = day, y = total_case_confirmed, color = country_region)) +
  geom_line(size = 0.5) +
  ggrepel::geom_text_repel(
    data = lab,
    aes(
      x = day,
      y = total_case_confirmed,
      label = glue::glue("{country_region} ({scales::number(total_case_confirmed)})")
    ),
    nudge_x = 1,
    nudge_y = 1,
    hjust = -0.5,
    segment.colour = "gray75",
    segment.size = 0.25
  ) +
  scale_x_continuous(
    expand = expansion(mult = c(0.02, 0.5)),
    breaks = scales::breaks_pretty()
  ) +
  scale_y_continuous(breaks = scales::breaks_pretty()) +
  labs(
    x = "Days since cumulative confirmed case reached 100",
    y = "Cumulative number of confirmed cases",
    title = "Coronavirus trajectory in the world",
    subtitle = "The confirmed novel cases of Coronavirus (COVID-19) increase rapidly soon after it reaches the<br>number of 100. <span style = 'color:#B48EADFF;'>Italy</span>, <span style = 'color:#EBCB8BFF;'>Spain</span> and the <span style = 'color:#A3BE8CFF;'>USA</span> share a similar rate of novel cases. The situation is still<br>early in <span style = 'color:#D08770FF;'>Canada</span>, but it seems to follow the same pattern. On a positive note, the rate seems to<br>stabilize in <span style = 'color:#BF616AFF;'>China</span>.",
    caption = "Data: https://github.com/CSSEGISandData/COVID-19\nVisualization: @philmassicotte"
  ) +
  scale_color_manual(
    values = c(
      "China" = "#BF616AFF",
      "Canada" = "#D08770FF",
      "Spain" = "#EBCB8BFF",
      "US" = "#A3BE8CFF",
      "Italy" = "#B48EADFF"
    )
  ) +
  theme(
    legend.position = "none",
    panel.border = element_blank(),
    panel.grid = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.major.y = element_line(size = 0.1, color = "gray50"),
    plot.background = element_rect(fill = "#3c3c3c"),
    panel.background = element_rect(fill = "#3c3c3c"),
    text = element_text(color = "white"),
    axis.text = element_text(color = "white"),
    plot.title = element_text(hjust = 0, family = "Lalezar"),
    plot.title.position = "plot",
    plot.caption = element_text(
      size = 6,
      color = "gray75",
      family = "Advent Pro"
    ),
    plot.subtitle = element_markdown(
      size = 8,
      family = "Montserrat Light",
      lineheight = 1.2,
      margin = margin(b = unit(25, "lines"))
    )
  )

ggsave(
  here::here("graphs", "covid19_cumulative_curves.png"),
  type = "cairo",
  dpi = 600
)