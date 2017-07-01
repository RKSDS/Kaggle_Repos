library("tidyr")
library("plyr")
library(ggplot2)
library(stringr)

#import file from csv to df
imdb <- read.csv("./Extra DS/Kaggle/movie_metadata.csv", stringsAsFactors = F)

#structure of IMDB

str(imdb)

View(imdb)
imdb <- imdb[, -grep("movie_imdb_link", colnames(imdb))]
