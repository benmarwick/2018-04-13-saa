#-------------------------------------------------------------
# SAA2018 Workshop: Using R for Archaeological Data Analysis
# Washington DC
# Friday 13 April 2018, 
# Ben Marwick, with Matt Harris and Jon Clindaniel 
#-------------------------------------------------------------
#
# Workshop schedule
#
# Start time	End time	Topic
# 9:30	9:45	Introduction to R and RStudio
# 9:45	10:00	Importing, inspecting & cleaning data from spreadsheets
# 10:00	10:15	Exploratory Data Analysis with dplyr & tidyr
# 10:15	10:30	Exploratory Data Analysis with dplyr & tidyr
# 10:30	10:45	Visualising data with ggplot & plotly
# 10:45	11:00	Visualising data with ggplot & plotly
# 11:00	11:15	Break
# 11:15	11:30	Hypothesis testing: two samples
# 11:30	11:45	Hypothesis testing: more than two samples
# 11:45	12:00	Hypothesis testing: count data
# 12:00	12:15	Break
# 12:15	12:30	Importing & mapping GIS data with sf & google maps
# 12:30	12:45	Spatial data analysis: spatial joins
# 12:45	1:00	Spatial data analysis: point pattern analysis


#  Interacting with R & RStudio ---------------------------------------------------

# - quick tour of console, script editor, plots, environment
# - using console as calculator, assigning values to objects, using objects

2 + 3
x <- 2
y <- 3
x + y
z <- x + y

# if you get stuck with a "+" symbol instead of a ">" symbol,
# e.g., type this in console and press enter: 2 + 3 + 
# then you just need to press ESC (windows) or CTRL + C (Mac) 
# to interrupt and get back to the normal prompt. 

# - commenting code
# - using functions

x <- c(4, 7, 12) # length measurements of three artefacts
# this is a vector! a sequence of elements of same type
x

y <- mean(x)     # compute the mean length
?mean            # get help on a specific function
??median         # search help docs

# - packages

# all the best pkgs for archaeology are listed here:
# https://github.com/benmarwick/ctv-archaeology

# how to install, from the R prompt, assuming we are online:

# install.packages("readr") # wait a few moments
# install.packages("readxl")

# - getting help: 
# -- searching google with the phrase: "r help [your task or error message]"
# -- Stackoverflow, email lists, great advice for using: http://jennybc.github.io/reprex/
# -- self-teaching: swirl, https://www.rstudio.com/resources/cheatsheets/, r-bloggers.com

# Importing tabular data  ---------------------------------------------------

#- working directory
#-- important concept for getting, and staying, organised with your files. 
#-- we set with Session -> Set Working Directory -> To source file location

#- Import CSV and Excel files, tab-complete!

library(readr)
# data from http://dx.doi.org/10.1016/j.jas.2016.10.010
ktc_ceramic_data <- read_csv("data/ktc_ceramic_data.csv")
# this is a data frame: a basic tabular structure, very common in R. Each column can contain only one type of data, typically numeric, character, logical, and a few more exotic ones
View(ktc_ceramic_data)

library(readxl)
# data from http://dx.doi.org/10.1016/j.jhevol.2016.09.004
jerimalai_lithics <- read_excel("data/jerimalai_lithics.xlsx")
# output is data frame

#- tables in word docs and PDFs are possible too, but we will not do those today

#-  Import multiple files

# just two steps:

# create a list of files that we want to import
my_list_of_files <- list.files(path = "data/many_excel_files/",
                               full.names = TRUE)
# this is a character vector: a sequence of values that all have the type 'character'

# to inspect this vector, we use the square bracket notation:

my_list_of_files[1]

my_list_of_files[1:2]

library(purrr)
data_from_my_files <- map(my_list_of_files,
                          ~read_excel(.x))  # .x refers to each item in my_list_of_files
# this is a list: a sequence of values that can be of different types

# to inspect this list, we also use square bracket notation, but with subtle differences:

data_from_my_files[[1]]
data_from_my_files[1:2]

#  Inspecting & cleaning data ---------------------------------------------------

# - basic functions for seeing what we have

# show structure
str(y) # vector
str(ktc_ceramic_data)      # data frame
str(jerimalai_lithics)     

## do CTRL + L to clear console ##

# a nicer look a structure for data frames
library(dplyr)
glimpse(ktc_ceramic_data)

# look at the first and last parts
head(ktc_ceramic_data)
tail(ktc_ceramic_data)

# get column names
names(jerimalai_lithics)

# see as table in RStudio, can sort (by EU) and filter (for CC) easily
View(ktc_ceramic_data)

# - indexing with [ , ] and $

# to get a single column from a data frame, use $

j_weights <- jerimalai_lithics$Weight
mean(j_weights) # NA , why?
?mean           # check help documentation
mean(j_weights, na.rm = TRUE) # ok!

# to subset certain rows or columns from a data frame, use [ row , column ]

# we can use numbers
jerimalai_lithics[ 1:10, ]     # rows 1-10,  all cols
jerimalai_lithics[ 1:10, 1:4]  # rows 1-10, cols 1-4 only

# - cleaning the data before analysing

# often our data are not in exactly the right form for analysis

# 5CC: five cleaning chores
# 1. removing spaces
# 2. fixing typos
# 3. contaminated numbers
# 4. type conversion
# 5. missing values

# some simple example data
dirty_data <- c("green", "green", "green ", "Green", "gren", "geen")

# see how many variants we have
unique(dirty_data)
table(dirty_data)

# 1. Extra spaces are frequently a pain! They can be hard to spot, but are a very common hurdle when working with data

# we can remove the spaces with the function gsub
# " " is the space, "" is what we replace it with, ie. nothing
library(stringr)
dirty_data_no_spaces <- str_squish(dirty_data) # cf. str_squish

# 2. Fixing typos: upper and lower case, spelling mistakes

# We want everything to be the same case
dirty_data_same_case <- str_to_lower(dirty_data_no_spaces)

# We want to correct a spelling mistake

# ifelse is one way
dirty_data_spelling_fixed <- ifelse(dirty_data == "gren",
                                    "Green",
                                    dirty_data)
# these can be nested, so ifelse(..., ifelse(..., )) etc. 

# gsub is another way to do this
dirty_data_spelling_fixed <- str_replace_all(dirty_data, "gren", "Green")

# we can get more than one typo at once:
dirty_data_spelling_fixed <- str_replace_all(dirty_data, "gren|geen", "Green")

# 3. Contaminated numbers

dirty_numbers <- c(2.4, 3.7, "5.4mm", 1.1, "2.5 mm", "<0.01")

# how to get rid of the non-digit characters? (i.e. spaces, letters and symbols)
library(readr)
dirty_numbers_cleaned <- parse_number(dirty_numbers)

# how can we separate into letters and numbers? or any kind of separation?
combo_numbers <- data.frame(contexts = c("1A", "1B", "1C", "2A", "2B", "2C", NA),
                            artefact_counts = sample(7))

# how can we separate into letters and numbers? or any kind of separation?
library(tidyr) # wonderful package http://r4ds.had.co.nz/tidy-data.html

combo_numbers_separated <- 
  separate(combo_numbers,  # data frame name
           contexts,       # column name
           into = c("major_context",  # new col name
                    "minor_context"), # new col name
           sep = 1)        # where to split?

# 4. Type conversion

dirty_numbers <- c(3.1, 3.5, 4.7, 9.2, "very small")

# what type of vector is this?
typeof(dirty_numbers)

# A mix of numbers and characters is coerced by R so that all are characters
# That is a problem because we can't do mathematical operations on characters
# So, we must convert them to numbers like this

dirty_numbers_numeric <- as.numeric(dirty_numbers)

# what have we got now?
typeof(dirty_numbers_numeric)

# 5. Missing values

# Dealing with missing values requires some thought about what is meaningful in the context of your research question. Here are a few simple cases

# drop the missing value, two options that do the same thing:

# for a vector
dirty_numbers_numeric[!is.na(dirty_numbers_numeric)]
na.omit(dirty_numbers_numeric)

# for a data frame
library(dplyr)
combo_numbers %>% 
  filter(!is.na(contexts))

# often it is useful to see which rows of a data frame have missing data
combo_numbers %>% 
  filter(!complete.cases(contexts))


# Exploratory Data Analysis: reshaping & summarising --------------


# - 5MV of dplyr: filter, mutate, arrange, summarise, group_by 

library(dplyr) # more info: https://cran.r-project.org/web/packages/dplyr/vignettes/introduction.html

## Five Main Verbs: filter, mutate, arrange, summarise, group_by  ##

## 1. Filter ##

# filter to get only rows that match a condition
# equal to (equivalent to)
jerimalai_lithics %>% 
  filter(Material == "Chert")

# filter to get only rows that match conditions
# numeric greater/less than
jerimalai_lithics %>% 
  filter(Material == "Chert" &
           Weight > 0.5)

# filter to get only rows that match conditions
# numeric range of values, we can use >, <=, >=, ==, and !=
jerimalai_lithics %>% 
  filter(Material == "Chert" &
           Weight >= 0.5 & 
           Weight <= 5)

# filter to get only rows that match conditions
# match multiple conditions

# what materials do we have?
unique(jerimalai_lithics$Material) # the unique values
table(jerimalai_lithics$Material)  # each value appears in how many rows?

# use %in% to match with multiple stone types
jerimalai_lithics %>% 
  filter(Material %in% c("Chert", "Volcanic") &
           Weight > 0.5 & 
           Weight < 5)

## 2. Mutate ##

# add a new column by computing on other columns
jerimalai_lithics %>% 
  mutate(surface_area = Length * Weight)

## 3. Arrange ##

# sort ascending
jerimalai_lithics %>% 
  arrange(Weight)

# sort descending
jerimalai_lithics %>% 
  arrange(desc(Weight))

## 4. Summarise ##

jerimalai_lithics %>% 
  summarise(mean_weight = mean(Weight)) # why NA?

jerimalai_lithics %>% 
  summarise(mean_weight = mean(Weight, 
                               na.rm = TRUE))

# how about mean weight for all artefacts of one raw material?
jerimalai_lithics %>% 
  filter(Material == "Chert") %>% 
  summarise(mean_weight = mean(Weight,
                               na.rm = TRUE))
# what about for all raw materials? We need to use group_by...

## 5. Group by ##

# get counts of artefacts for each raw material
jerimalai_lithics %>% 
  group_by(Material)  %>% 
  tally() 

# arrange to see most abundant...
jerimalai_lithics %>% 
  group_by(Material)  %>% 
  tally() %>% 
  arrange(desc(n))

# use mutate to add column of percentages...
jerimalai_lithics_raw_materials <- 
  jerimalai_lithics %>% 
  group_by(Material)  %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  mutate(perc = n / sum(n) * 100)

# use round to  trim off unwanted decimal places...
jerimalai_lithics %>% 
  group_by(Material) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  mutate(perc = n / sum(n) * 100) %>% 
  mutate(perc = round(perc, 2))

# now back to the mean weights... here's what we can do:
jerimalai_lithics %>% 
  group_by(Material) %>% 
  summarise(mean_weight = mean(Weight, 
                               na.rm = TRUE),
            mean_length = mean(Length, 
                               na.rm = TRUE))

# compute means for all numeric columns!! incredibly efficient
jerimalai_lithics %>% 
  group_by(Material) %>% 
  summarise_if(is.numeric, 
               mean, 
               na.rm = TRUE)

# compute mean and standard devations for all numeric cols!!! incredible!
jerimalai_lithics %>% 
  group_by(Material) %>% 
  summarise_if(is.numeric, 
               funs(mean, sd), 
               na.rm = TRUE)

# see the cheatsheets for more amazing things you can do with dplyr!
# also lots of nice tutorials online be researchers documenting their use of dplyr


# - reshaping data with tidyr, wide <-> long -----------------------------

# this is a 'long table', typical from what we get from data entry,
# but not very readable or suitable for publication
jerimalai_lithics

library(tidyr) # key package for reshaping

# let's make a table of raw materials by spit
jerimalai_lithics_raw_materials_wide <- 
  jerimalai_lithics %>% 
  group_by(Spit, Material) %>% 
  tally() %>% 
  spread(Material, n, fill = 0) 

# this is getting closer to an easily readable table for publication
# we can reverse the process, from wide to long, using the 'gather' function


#  Exploratory Data Analysis: plotting & interactivity --------------------------------

## 
# - 5NP of ggplot2: histograms, bar plot, line plot, boxplots, scatter-plots 

## Five named plots: histograms, bar plot, line plot, boxplots, scatter-plots  ##

# how to choose which plot for your data?
# - http://extremepresentation.typepad.com/blog/2006/09/choosing_a_good.html
# further reading:
# -  "Creating More Effective Graphs" by Naomi Robbins. 

library(ggplot2) # good documentation at http://docs.ggplot2.org/current/ & http://www.cookbook-r.com/Graphs/

## 1. histogram ##

# good for showing the distribution of one variable

ggplot(jerimalai_lithics, 
       aes(Length)) +
  geom_histogram()

## 2. bar plot ##

# good for COUNTS ONLY of items in different categories
# DO NOT use for mean/median/etc distribution summaries

ggplot(jerimalai_lithics_raw_materials, 
       aes(Material,
           perc)) +
  geom_col()

# 2a. let's order the columns big to small
ggplot(jerimalai_lithics_raw_materials, 
       aes(reorder(Material, -perc),
           perc)) +
  geom_col()

# 2b. deal with long names on x-axis ticks
# flip plot
ggplot(jerimalai_lithics_raw_materials, 
       aes(reorder(Material, perc),
           perc)) +
  geom_col() +
  coord_flip()

# 2c. deal with long names on x-axis ticks
# rotate tick lables
ggplot(jerimalai_lithics_raw_materials, 
       aes(reorder(Material, perc),
           perc)) +
  geom_col() +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.5))

# 2d. customise axis labels
ggplot(jerimalai_lithics_raw_materials, 
       aes(reorder(Material, perc),
           perc)) +
  geom_col() +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.5)) +
  xlab("Raw material type") +
  ylab("Percentage")

# 2e.modify the theme, overall look, increase font size
ggplot(jerimalai_lithics_raw_materials, 
       aes(reorder(Material, perc),
           perc)) +
  geom_col() +
  theme_bw(base_size = 14) +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.5)) +
  xlab("Raw material type") +
  ylab("Percentage") 
# there are so many wonderful themes! Technical details: http://docs.ggplot2.org/dev/vignettes/themes.html
# add-on themes: https://www.ggplot2-exts.org/index.html, e.g. https://cran.r-project.org/web/packages/ggthemes/vignettes/ggthemes.html

## 3. line plot ## 

# good to show change over a continunous variable, such as time. 
# DO NOT use for discrete categories (types, locations, etc)

# 3a. basic, not very good
ggplot(jerimalai_lithics_raw_materials_wide,
       aes(x = Spit,
           y = Chert,
           group = 1)) +
  geom_line()

# 3b.one way to add another line
# ggplot(jerimalai_lithics_raw_materials_wide) +
#   geom_line(aes(x = Spit,
#                 y = Chert,
#                 group = 1)) +
#   geom_line(aes(x = Spit,
#                 y = Volcanic,
#                 group = 1),
#             colour = "red") 

# 3c. increase line thickness
ggplot(jerimalai_lithics_raw_materials_wide) +
  geom_line(aes(x = Spit,
                y = Chert,
                group = 1),
            size = 2) 

# 3d. set nice theme
ggplot(jerimalai_lithics_raw_materials_wide) +
  geom_line(aes(x = Spit,
                y = Chert,
                group = 1),
            size = 1.5) +
  theme_bw(base_size = 12)

# remember that line graphs MUST have continuous variable for x-axis!!

## 4. boxplot ##

# Best choice for showing distributions in different categories

# 4a. we have do some work to make this look good!
ggplot(jerimalai_lithics,
       aes(Material,
           Weight)) +
  geom_boxplot()

# 4b. there is a NA category, let's get rid of that
jerimalai_lithics_to_plot <- 
  jerimalai_lithics %>% 
  filter(Material != "NA")

# check it out...

ggplot(jerimalai_lithics_to_plot,
       aes(Material,
           Weight)) +
  geom_boxplot()

# no NA now

# 4c. use log scale for y-axis
ggplot(jerimalai_lithics_to_plot,
       aes(Material,
           Weight)) +
  geom_boxplot() +
  scale_y_log10()

# 4d. rotate x-axis labels
ggplot(jerimalai_lithics_to_plot,
       aes(Material,
           Weight)) +
  geom_boxplot() +
  scale_y_log10() +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.4))

# 4e. put categories in order
jerimalai_lithics_to_plot %>% 
  mutate(Material = fct_reorder(Material, -Weight)) %>% 
  ggplot(aes(Material,
           Weight)) +
  geom_boxplot() +
  scale_y_log10() +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.4))


# 4g. fix the axis titles
jerimalai_lithics_to_plot %>% 
  mutate(Material = fct_reorder(Material, -Weight)) %>% 
  ggplot(aes(Material,
             Weight)) +
  geom_boxplot() +
  scale_y_log10() +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.4)) +
  xlab("Raw Material") +
  ylab("Weight (g)")

# 4h. fix the y-axis tick labels
library(scales)
jerimalai_lithics_to_plot %>% 
  mutate(Material = fct_reorder(Material, -Weight)) %>% 
  ggplot(aes(Material,
             Weight)) +
  geom_boxplot() +
  scale_y_log10(labels = comma) + # nice axis tick labels
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.4)) +
  xlab("Raw Material") +
  ylab("Weight (g)")

# 4i. use nice theme
jerimalai_lithics_to_plot %>% 
  mutate(Material = fct_reorder(Material, -Weight)) %>% 
  ggplot(aes(Material,
             Weight)) +
  geom_boxplot() +
  scale_y_log10(labels = comma) + 
  theme_minimal() + #  nice theme
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.4)) +
  xlab("Raw Material") +
  ylab("Weight (g)")

# this is excellent, suitable for publication, and better than many we see in papers

# 4j. one further improvement we can make is to show the data for each individual artefact

library(ggforce)
jerimalai_lithics_to_plot %>% 
  mutate(Material = fct_reorder(Material, -Weight)) %>% 
  ggplot(aes(Material,
             Weight)) +
  geom_boxplot() +
  geom_sina(alpha = 0.005) + # experiment with the value for alpha
  scale_y_log10(labels = comma) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.4)) +
  xlab("Raw Material")  +
  ylab("Weight (g)")

# Gives more information about the data - which category has the most artefacts, 
# what the shape of the distribution is in more detail

# This is my current default for boxplots for my publications, & I request it in peer reviews

## 5. scatterplot ##

# 5a. basic
ggplot(jerimalai_lithics_to_plot,
       aes(Length,
           Width)) +
  geom_point()

# 5b. add another variable with colour
ggplot(jerimalai_lithics_to_plot,
       aes(Length,
           Width,
           colour = Material)) +
  geom_point()

#  too many materials! Let's filter out a bunch
jerimalai_lithics_to_plot_raw_materials <- 
  jerimalai_lithics_to_plot %>% 
  filter(Material %in% c( "Volcanic",
                         "Silcrete"))

# 5c. or use point shape, only good with small number of larger points
ggplot(jerimalai_lithics_to_plot_raw_materials,
       aes(Length,
           Width,
           shape = Material)) +
  geom_point()

# 5d. add another variable with point size
ggplot(jerimalai_lithics_to_plot_raw_materials,
       aes(Length,
           Width,
           colour = Material,
           size = Weight)) +
  geom_point()

# 5e. adjust point size to an arbitrary size
ggplot(jerimalai_lithics_to_plot_raw_materials,
       aes(Length,
           Width,
           colour = Material)) +
  geom_point(size = 1)

# 5f. add a line of best fit
ggplot(jerimalai_lithics_to_plot_raw_materials,
       aes(Length,
           Width,
           colour = Material)) +
  geom_point(size = 1) +
  geom_smooth()

# 5g. we get one line per colour, if we want one line for all points
# we do this

ggplot(jerimalai_lithics_to_plot_raw_materials,
       aes(Length,
           Width)) +
  geom_point(aes(colour = Material),
             size = 1) +
  geom_smooth()

# 5h. default best fit line is loess, but if we want linear regression line...

ggplot(jerimalai_lithics_to_plot_raw_materials,
       aes(Length,
           Width)) +
  geom_point(aes(colour = Material),
             size = 1) +
  geom_smooth(method = "lm")

# 5i. and if we want to show the linear model equation on the plot...

library(ggpmisc)
my.formula <- y ~ x
ggplot(jerimalai_lithics_to_plot_raw_materials,
       aes(Length,
           Width
       )) +
  geom_point(aes(colour = Material),
             size = 1) +
  geom_smooth(method = "lm", 
              se = FALSE, 
              color = "black", 
              formula = my.formula) +
  stat_poly_eq(formula = my.formula, 
               aes(label = paste(..eq.label.., 
                                 ..rr.label.., 
                                 sep = "~~~")), 
               parse = TRUE)

# 5j. and finally, apply a theme, and adjust axis titles

ggplot(jerimalai_lithics_to_plot_raw_materials,
       aes(Length,
           Width)) +
  geom_point(aes(colour = Material),
             size = 1) +
  geom_smooth(method = "lm", 
              se = FALSE, 
              color = "black", 
              formula = my.formula) +
  stat_poly_eq(formula = my.formula, 
               aes(label = paste(..eq.label.., 
                                 ..rr.label.., 
                                 sep = "~~~")), 
               parse = TRUE) +
  theme_bw() +
  xlab("Length (mm)") +
  ylab("Width (mm)")

## 5k. bonus feature: facetting ##

ggplot(jerimalai_lithics_to_plot_raw_materials,
       aes(Width,
           Length)) +    # plot
  geom_point() +
  geom_smooth(method = "lm") +
  facet_wrap( ~ Material)

# 5l. say we want 1:1 scaling on the axes

ggplot(jerimalai_lithics_to_plot_raw_materials,
       aes(Width,
           Length)) +    # plot
  geom_point() +
  geom_smooth(method = "lm") +
  facet_wrap( ~ Material) +
  coord_equal()

# and you know the rest for axis titles, themes, etc

## 5m. bonus feature: interactivity ##

library(plotly) # excellent documentation at https://plot.ly/r/

j_silcrete <- 
  jerimalai_lithics_to_plot_raw_materials %>% 
  filter(Material == "Silcrete") %>% 
  ggplot(aes(Length,
             Width)) +
  geom_point()

# presto! interactive!
ggplotly(j_silcrete) # hover your mouse over the points

# if we want custom info in mouse-over popup...

j_silcrete <- 
  jerimalai_lithics_to_plot_raw_materials %>% 
  filter(Material == "Silcrete") %>% 
  ggplot(aes(Length,
             Width)) +
  geom_point(aes(text = paste("Spit: ", Spit)))

ggplotly(j_silcrete)

# amazing! super useful for interactive work
# for point labels on static plots, use the ggrepel package

## 5n. bonus feature: saving plots ##

# two methods: ggsave (recommended!!) and RStudio Plots pane

# draw plot, e.g.
j_silcrete
# then use ggsave to get PNG
ggsave(filename = "j_silcrete.png",
       width = 10,
       height = 10, 
       units = "cm",
       dpi = 600) # not less than 300 for publication
# can take some trial and error to get the size and dpi looking good

# or save as SVG and edit in Inkscape (e.g. combine with other graphics) to make PNG
ggsave(filename = "j_silcrete.svg",
       width = 10,
       height = 10, 
       units = "cm")

# plots pane, Export -> Save As image... -> adjust size, proportions and location, then save
# best for quick plots to share with collaborators

# Significance testing ---------------------------------------------------

# Testing - let's do three very common stat tests

# for more on how to choose the right test:
# - table: http://www.biostathandbook.com/testchoice.html
# - flowchart: http://www.biochemia-medica.com/content/comparing-groups-statistical-differences-how-choose-right-statistical-test   
# - many examples in R: http://stats.idre.ucla.edu/other/mult-pkg/whatstat/ 


## Testing for the difference in measurements of two samples 

# Very common statistical test, for testing if two samples differ
# for example, length of artefacts of two different raw materials. 

jerimalai_lithics_to_plot_si_vo <- 
  jerimalai_lithics_to_plot %>% 
  filter(Material %in% c("Silcrete", 
                         "Volcanic"))

# - normality check:  visual & shapiro.test() & qqnorm()

# 1. take a look, not very normally distributed, long right tails
ggplot(jerimalai_lithics_to_plot_si_vo,
       aes(Length)) +
  geom_histogram() +
  facet_wrap( ~ Material, 
              ncol = 1,
              scales = "free_y")

# 2. statisitical test for normality of each sample

# using the purr package

library(broom)
jerimalai_lithics_to_plot_si_vo %>%         # take the data frame...
  nest(-Material) %>%                       # nest
  mutate(shpr_test = map(data, ~shapiro.test(.x$Length))) %>%  #test on each df
  mutate(test_out =  map(shpr_test, tidy)) %>%  # tidy up
  unnest( test_out )                        # unnest so we can see

# in any case, the p-value is very low, so it confirms our visual assessment, 
# so we should use a test that does not depend on the data having a normal distribution

# 3. statistical test for difference between the two samples

wilcox.test(Length ~ Material,  # the ~ is the formula interface, we can read ~ as 'by', or 'a function of'
            data = jerimalai_lithics_to_plot_si_vo)

# How to use the formula interface: LHS ~ RHS where LHS is a numeric variable giving the data values and RHS a factor/character with two levels giving the corresponding groups.

# another way to type it:

with(jerimalai_lithics_to_plot_si_vo, 
     wilcox.test(Length ~ Material))

# result is p < 0.05, so we say yes, they are significantly different in length

#  Testing for the difference in measurements of three or more samples -----------------------

# For example, does the Weight of the artefact vary across 4 different raw materials?

jerimalai_lithics_to_plot_4 <- 
  jerimalai_lithics_to_plot %>% 
  filter(Material %in% c("Silcrete", 
                         "Volcanic",
                         "Chert",
                         "Quartzite"))

# 1. check for the normality of the weight measurements

ggplot(jerimalai_lithics_to_plot_4,
       aes(Weight)) +
  geom_histogram() +
  facet_wrap( ~ Material, 
              ncol = 1,
              scales = "free_y") 
# very hard to see anything!
# try log scale

ggplot(jerimalai_lithics_to_plot_4,
       aes(Weight)) +
  geom_histogram() +
  facet_wrap( ~ Material, 
              ncol = 1,
              scales = "free_y") +
  scale_x_log10()

# log scale is better to see distribution when squashed up at one end (this case, the small end)

# we can also use the boxplot effectively here
ggplot(jerimalai_lithics_to_plot_4,
       aes(Material,
           Weight)) +
  geom_boxplot() +
  geom_sina(alpha = 0.01) +
  scale_y_log10()

# def not normal!

# 2. Do the stat test for differences in measurement by the groups
# for non-normal distributions, we can use the Kruskal-Wallis Rank Sum Test
# more: http://rcompanion.org/rcompanion/d_06.html

with(jerimalai_lithics_to_plot_4, 
     kruskal.test(Weight ~ as.factor(Material)))

#  post-hoc test to see where the significant difference is
#  for the non-normal situation like this, we use the Dunn test


library(FSA)

my_dunn_test <- 
  with(jerimalai_lithics_to_plot_4, 
       dunnTest(Weight ~ as.factor(Material),
                method="bh"))

# check it out
my_dunn_test

# examine the data frame, and arrange by P.adj values
str(my_dunn_test)
# here's the data
my_dunn_test$res
arrange(my_dunn_test$res, P.adj)

# so all pairs except  Quartzite - Volcanic  are significantly different



# Testing for difference in counts  --------------

# For example, are there significantly different numbers of raw materials in the different spits

# summarise the data into a wide table...
jerimalai_lithics_chi_sq_test <- 
  jerimalai_lithics_to_plot_4 %>% 
  group_by(Spit, Material) %>% 
  tally() %>% 
  spread(Material, n, fill = 0) %>% 
  ungroup() %>% 
  select(-Spit) 

# compute the test
jerimalai_lithics_chi_sq_test_result <- chisq.test(jerimalai_lithics_chi_sq_test)

# p-value indicates that we really do have a significant difference in the number of sherds in each stratigraphic context

# visualise 
library(infer)
jerimalai_lithics_to_plot_4 %>% 
  mutate(Spit_fct = factor(Spit)) %>% 
  specify(Spit_fct ~ Material) %>% 
  hypothesize(null = "independence") %>% 
  generate(reps = 1000,
           type = "permute") %>% 
  calculate(stat = "Chisq") %>% 
  visualize() +
  geom_vline(xintercept = jerimalai_lithics_chi_sq_test_result$statistic, 
             colour = "red", 
             size = 1)


# to get more information, we can look at the residuals:

jerimalai_lithics_chi_sq_test_result$residuals

# A general rule of thumb for figuring out what the standardized residual means, is:
# If the residual is less than -2, the cell’s observed frequency is less than the expected frequency. Greater than 2 and the observed frequency is greater than the expected frequency.

# Importing & visualising GIS data ---------------------------------------------------


# import points as spreadsheet, this is just a simple spreadsheet with one point (site) per row, and UTM coordinates in two columns 

library(readr)
pottery <- read_csv("data/pottery.csv")

# subset as it's rather large
pottery <- pottery[sample(1000), ]

# data from https://doi.org/10.5284/1024569
# UTM WGS84 Zone 34N coordinate system

# plot with ggplot, like a simple scatter plot
library(ggplot2)
ggplot(pottery,
       aes(Xsugg, 
           Ysugg)) +
  geom_point() +
  coord_equal() # this is important for maps


# show using ggmap

#  Let’s assume these data are WGS84, 
# which is CRS=4326, and one of the most commonly used for mapping purposes. 
library(sf)
pottery_sf_utm <- st_as_sf(pottery, coords = c("Xsugg", "Ysugg"), crs = 32634)
pottery_sf_latlong <- st_transform(pottery_sf_utm, crs = 4326)

# add coordinates to dataframe
pottery_sf_latlong$lon<-st_coordinates(pottery_sf_latlong)[,1] # get coordinates
pottery_sf_latlong$lat<-st_coordinates(pottery_sf_latlong)[,2] # get coordinates

map_center <-  c(x = mean(pottery_sf_latlong$lon), 
                 y = mean(pottery_sf_latlong$lat))

library(ggmap)
# get base map data from http://maps.googleapis.com
base_map <- get_googlemap(center = map_center,
                       zoom = 12, # experiment with this
                       scale = 2,
                       maptype = "terrain")


p <- ggmap(base_map) +
    geom_point(data = pottery_sf_latlong, 
               aes(lon,
                   lat),
            col="red", 
            size=1) +
  xlab("Longitude") +
  ylab("Latitude") +
  labs(title = "My map of some points",
       subtitle = "Archaeological sites in XXX Province",
       label = paste0("Map data copyright Google ", 
                      format(Sys.Date(), "%Y")))

# add scale bar and legend:
# https://gist.github.com/benmarwick/d2ff752ed03432ea648bee7903c234b3#file-basic_point_map-r-L57


# add polygons, import shapefile as simple features object
geology <- st_read("data/geology/geology.shp")

# let's look at the polygon by itself, plot with ggplot

ggplot(geology) +  
  geom_sf() 

# and now the points and the polygons together
# we must convert the pottery df to an sf object, with 
# the CRS as the geology

st_crs(pottery_sf) <-  st_crs(geology)

ggplot() +  
  geom_sf(data = geology)  +
  geom_sf(data = pottery_sf)

# can show more info

ggplot() +  
  geom_sf(data = geology,
          aes(fill = Type))  +
  geom_sf(data = pottery_sf, 
          aes(colour = SherdNo )) +
  theme_minimal()

#- points in polygons

# a typical question is how many points are in each polygon? 

# do a spatial join, take the pottery data, and for each point, add cols
# from the geology polygon that contains it

pottery_in_geology <- 
  geology  %>% 
  st_join(pottery_sf)

# We can tally up how many points in each polygon...
pottery_in_geology %>% 
  group_by(Type) %>% 
  summarise(n = n()) %>% # count the points
  arrange(desc(n))

# but more useful is number of points per unit area, so let's compute that:

pottery_in_geology_density <- 
pottery_in_geology %>% 
  group_by(Type, Area) %>% 
  summarise(n = n()) %>% # count the points
  mutate(sherds_per_area = n / Area) %>% 
  arrange(desc(sherds_per_area)) 

# we can plot this
pottery_in_geology_density %>% 
  ggplot(aes(reorder(Type, -sherds_per_area),
             sherds_per_area)) +
         geom_boxplot() +
  scale_y_log10() +
  coord_flip()


# and we can map it
library(viridis)
ggplot(pottery_in_geology_density) +
  geom_sf(aes(fill = sherds_per_area )) +
  scale_fill_viridis(trans = "log")



#- point pattern analysis

library(spatstat) # see http://spatstat.github.io/

# compare point patterns in two geological units

pottery_in_Flysch <- 
  pottery_joined_to_geology %>% 
  filter(Type == "Flysch")

pottery_in_Rudist <- 
  pottery_joined_to_geology %>% 
  filter(Type == "Rudist bearing limestones")

# we need to create a new type of object, 'Planar point pattern'
pottery_in_Flysch_coords <- pottery_in_Flysch[ , c("Xsugg", "Ysugg")]
pottery_in_Flysch_ppp <- 
  as.ppp(pottery_in_Flysch_coords,
         owin(range(pottery_in_Flysch_coords[ , 1]),
              range(pottery_in_Flysch_coords[ , 2])))

pottery_in_Rudist_coords <- pottery_in_Rudist[ , c("Xsugg", "Ysugg")]
pottery_in_Rudist_ppp <- 
  as.ppp(pottery_in_Rudist_coords,
         owin(range(pottery_in_Rudist_coords[ , 1]),
              range(pottery_in_Rudist_coords[ , 2])))

# compute Ripley's K for randomness of point distribution
pottery_in_Flysch_ppp_K <- envelope(pottery_in_Flysch_ppp, Kest, global=TRUE)
pottery_in_Rudist_ppp_K <- envelope(pottery_in_Rudist_ppp, Kest, global=TRUE)

# visualise results
par(mfrow=c(2,2))
plot(pottery_in_Flysch_ppp)
plot(pottery_in_Rudist_ppp)
plot(pottery_in_Flysch_ppp_K)
plot(pottery_in_Rudist_ppp_K)





