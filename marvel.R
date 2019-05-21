if (!require(wordcloud)) {
  install.packages("wordcloud", repos="http://cran.us.r-project.org")
}
if (!require(tm)) {
  install.packages("tm", repos="http://cran.us.r-project.org")
}
if (!require(slam)) {
  install.packages("slam", repos="http://cran.us.r-project.org")
}
if (!require(SnowballC)) {
  install.packages("SnowballC", repos="http://cran.us.r-project.org")
}
if (!require(ggplot2)) {
  install.packages("ggplot2", repos="http://cran.us.r-project.org")
}
if (!require(xts)) {
  install.packages("xts", repos="http://cran.us.r-project.org")
}
if (!require(textclean)) {
  install.packages("textclean", repos="http://cran.us.r-project.org")
}
if (!require(tidytext)) {
  install.packages("tidytext", repos="http://cran.us.r-project.org")
}
library(slam)
library(tm)
library(wordcloud)
library(SnowballC)
library(ggplot2)
library(xts)
library(textclean)
library(tidytext)
library(syuzhet)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(sentimentr, dplyr, magrittr)
library('sentimentr')

workingDir = '/Users/michaeltauberg/projects/marvel/'
csvName = "script_data.csv"
data_name = "marvel"
setwd(workingDir)
#dt = read.csv(file=csvName, stringsAsFactors=FALSE, fileEncoding="utf-8")
dt = read.csv(file=csvName)
dt$character = gsub("\\[", "", dt$character)
#dt$character = tolower(dt$character)
dt$character = as.factor(dt$character)
#dt[dt$character == "fury",]$character = "nick fury"
#dt[dt$character == "banner",]$character = "bruce banner"
#dt[dt$character == "barton",]$character = "clint barton"


################
# NUMBER OF LINES
###############
#num_character_lines = data.frame(character=rep("", length(levels(dt$character))), num_lines=rep("", length(levels(dt$character))), stringsAsFactors=FALSE) 
#i = 1
#for(character in levels(dt$character)) {
#  print(character)
  #character_lines =  dt[dt$character == character,]
#  character_lines = dt[grep(character, dt$character),] 
#  num_lines = nrow(character_lines)
#  num_character_lines[i,] = c(character, num_lines)
#  i = i + 1
#}
num_character_lines = data.frame(character=rep("", length(levels(dt$character))), num_lines=rep("", length(levels(dt$character))), stringsAsFactors=FALSE) 
i = 1
for(character in levels(dt$character)) {
  print(character)
  #character_lines =  dt[dt$character == character,]
  character_lines = dt[dt$character == character,] 
  num_lines = nrow(character_lines)
  num_character_lines[i,] = c(character, num_lines)
  i = i + 1
}
num_character_lines$num_lines = strtoi(num_character_lines$num_lines)
num_character_lines = num_character_lines[order(num_character_lines$num_lines, decreasing=TRUE),]
num_character_lines$character = as.factor(num_character_lines$character)

main_characters = c("tony", "thor", "steve", "peter parker", "peter quill", "natasha")
main_characters = c(main_characters, "scott", "loki", "nick fury", "rocket", "pepper", "bruce", "gamora")
main_characters = c(main_characters, "hank", "sam wilson", "odin", "drax", "clint")

#main_character_lines = data.frame(character=rep("", length(main_characters)), num_lines=rep("", length(main_characters)), stringsAsFactors=FALSE) 
#i = 1
#for (character in main_characters) {
#  character_lines = num_character_lines[num_character_lines$character == character,]
#  main_character_lines[i,] = c(character, character_lines$num_lines)
#  i = i + 1
#}
main_character_lines$character = as.factor(main_character_lines$character)
main_character_names = c("Tony Stark", "Thor", "Steve Rogers", "Peter Parker", "Peter Quill", "Natasha Romanov")
main_character_names = c(main_character_names, "Scott Lang", "Loki", "Nick Fury", "Rocket Raccoon", "Pepper Potts", "Bruce Banner", "Gamora")
main_character_names = c(main_character_names, "Sam Wilson", "Odin", "Drax", "Clint Barton")
main_character_names = c(main_character_names, "T'challa", "Happy Hogan", "Vision", "Wanda Maximoff")
main_character_lines = data.frame(character=rep("", length(main_character_names)), num_lines=rep("", length(main_character_names)), stringsAsFactors=FALSE) 
i = 1
for (character in main_character_names) {
  character_lines = num_character_lines[num_character_lines$character == character,]
  main_character_lines[i,] = c(character, character_lines$num_lines)
  i = i + 1
}

main_character_lines$character = main_character_names
main_character_lines$num_lines = strtoi(main_character_lines$num_lines)
main_character_lines$character = factor(main_character_lines$character, levels = main_character_lines$character[order(main_character_lines$num_lines, decreasing=FALSE)])
data_name = "character_lines"
p = ggplot(main_character_lines, aes(x=character, y=num_lines, fill="#003b9b")) + geom_bar(stat="identity") 
p = p + ggtitle("Number of Lines per Marvel Character")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + theme(axis.text=element_text(size=16,face="bold"), axis.title=element_text(size=13), axis.title.y=element_blank())
p = p + theme(plot.title = element_text(size=18,face="bold"))
p = p + ylab("Number of Lines") + guides(fill=FALSE)
p = p + coord_flip()
p = p + scale_fill_manual(values = c("#003b9b"))
ggsave(filename = sprintf("./%s.png", data_name) , plot=p, width=8, height=6)

###############
# NUMBER OF WORDS
###############
main_character_words = data.frame(character=rep("", length(main_character_names)), num_words=rep("", length(main_character_names)), stringsAsFactors=FALSE) 
i = 1
for (character in main_character_names) {
  character_lines = dt[dt$character == character,]
  character_words = sum(sapply(strsplit(as.character(character_lines$dialogue), " "), length))
  main_character_words[i,] = c(character, character_words)
  i = i + 1
}
data_name = "character_words"
main_character_words$num_words = strtoi(main_character_words$num_words)
main_character_words$character = factor(main_character_words$character, levels = main_character_words$character[order(main_character_words$num_words, decreasing=FALSE)])
p = ggplot(main_character_words, aes(x=character, y=num_words, fill="#a36563")) + geom_bar(stat="identity") 
p = p + ggtitle("Number of Words per Marvel Character")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + theme(axis.text=element_text(size=16,face="bold"), axis.title=element_text(size=13), axis.title.y=element_blank())
p = p + theme(plot.title = element_text(size=18,face="bold"))
p = p + ylab("Number of Words") + guides(fill=FALSE)
p = p + coord_flip()
p = p + scale_fill_manual(values = c("#a36563"))
ggsave(filename = sprintf("./%s.png", data_name) , plot=p, width=8, height=6)

################
# NUMBER OF MOVIES
################
num_character_movies = data.frame(character=rep("", length(main_character_names)), num_movies=rep("", length(main_character_names)), stringsAsFactors=FALSE)
i = 1
for(character in main_character_names) {
  print(character)
  character_movies = dt[dt$character == character,] 
  num_movies = length(levels(droplevels(character_movies$movie)))
  num_character_movies[i,] = c(character, num_movies)
  i = i + 1
}
num_character_movies$num_movies = strtoi(num_character_movies$num_movies)
num_character_movies$character = factor(num_character_movies$character, levels = num_character_movies$character[order(num_character_movies$num_movies, decreasing=FALSE)])

data_name = "character_movies"
p = ggplot(num_character_movies, aes(x=character, y=num_movies, fill="#82135f")) + geom_bar(stat="identity") 
p = p + ggtitle("Number of Movie Appearances per Marvel Character")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + theme(axis.text=element_text(size=16,face="bold"), axis.title=element_text(size=13), axis.title.y=element_blank())
p = p + theme(plot.title = element_text(size=18,face="bold"))
p = p + ylab("Number of Movies") + guides(fill=FALSE)
p = p + coord_flip()
p = p + scale_fill_manual(values = c("#82135f"))
p = p + scale_y_discrete(limits = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))
ggsave(filename = sprintf("./%s.png", data_name) , plot=p, width=8, height=6)

###########
# SALARIES
##########
salaries = read.csv("salaries.csv")
salaries$actor = factor(salaries$actor, levels = salaries$actor[order(salaries$salary, decreasing=FALSE)])
data_name = "salaries"
p = ggplot(salaries, aes(x=actor, y=salary, fill="#008224")) + geom_bar(stat="identity") 
p = p + ggtitle("Top Salaries of Marvel Movie Actors")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + theme(axis.text=element_text(size=16,face="bold"), axis.title=element_text(size=13), axis.title.y=element_blank())
p = p + theme(plot.title = element_text(size=18,face="bold"))
p = p + ylab("Top Salary") + guides(fill=FALSE)
p = p + coord_flip()
p = p + scale_fill_manual(values = c("#008224"))
ggsave(filename = sprintf("./%s.png", data_name) , plot=p, width=8, height=6)

###################
# NETWORK CONNECTIONS
####################
connections = read.csv("connections2.csv")
connections$character = factor(connections$character, levels = connections$character[order(connections$connections, decreasing=FALSE)])
connections = connections[1:15,]
data_name = "connections"
p = ggplot(connections, aes(x=character, y=connections, fill="#e5d5b5")) + geom_bar(stat="identity") 
p = p + ggtitle("Number of Connections to Other Marvel Characters")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + theme(axis.text=element_text(size=16,face="bold"), axis.title=element_text(size=13), axis.title.y=element_blank())
p = p + theme(plot.title = element_text(size=18,face="bold"))
p = p + ylab("Number of Connections") + guides(fill=FALSE)
p = p + coord_flip()
p = p + scale_fill_manual(values = c("#e5d5b5"))
ggsave(filename = sprintf("./%s.png", data_name) , plot=p, width=9, height=8)

centrality = read.csv("centrality.csv")
centrality = centrality[1:15,]
centrality$degree_centrality = as.numeric(as.character(centrality$degree_centrality))
centrality$character = factor(centrality$character, levels = centrality$character[order(centrality$degree_centrality, decreasing=FALSE)])
data_name = "centrality"
p = ggplot(centrality, aes(x=character, y=degree_centrality, fill="#e5d5b5")) + geom_bar(stat="identity") 
p = p + ggtitle("Centrality of Marvel Characters")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + theme(axis.text=element_text(size=16,face="bold"), axis.title=element_text(size=13), axis.title.y=element_blank())
p = p + theme(plot.title = element_text(size=18,face="bold"))
p = p + ylab("Degree Centrality") + guides(fill=FALSE)
p = p + coord_flip()
p = p + scale_fill_manual(values = c("#e5d5b5"))
ggsave(filename = sprintf("./%s.png", data_name) , plot=p, width=9, height=8)

centrality = read.csv("betweenness.csv")
centrality = centrality[1:15,]
centrality$centrality = as.numeric(as.character(centrality$centrality))
centrality$character = factor(centrality$character, levels = centrality$character[order(centrality$centrality, decreasing=FALSE)])
data_name = "betweenness"
p = ggplot(centrality, aes(x=character, y=centrality, fill="#e5d5b5")) + geom_bar(stat="identity") 
p = p + ggtitle("Betweeness Centrality of Marvel Characters")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + theme(axis.text=element_text(size=16,face="bold"), axis.title=element_text(size=13), axis.title.y=element_blank())
p = p + theme(plot.title = element_text(size=18,face="bold"))
p = p + ylab("Betweeness Centrality Score") + guides(fill=FALSE)
p = p + coord_flip()
p = p + scale_fill_manual(values = c("orange"))
ggsave(filename = sprintf("./%s.png", data_name) , plot=p, width=9, height=8)

centrality = read.csv("eigenvectors.csv")
centrality = centrality[1:15,]
centrality$centrality = as.numeric(as.character(centrality$centrality))
centrality$character = factor(centrality$character, levels = centrality$character[order(centrality$centrality, decreasing=FALSE)])
data_name = "eigenvector"
p = ggplot(centrality, aes(x=character, y=centrality, fill="#e5d5b5")) + geom_bar(stat="identity") 
p = p + ggtitle("Eigenvector Centrality of Marvel Characters")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + theme(axis.text=element_text(size=16,face="bold"), axis.title=element_text(size=13), axis.title.y=element_blank())
p = p + theme(plot.title = element_text(size=18,face="bold"))
p = p + ylab("Eigenvector Centrality Score") + guides(fill=FALSE)
p = p + coord_flip()
p = p + scale_fill_manual(values = c("pink"))
ggsave(filename = sprintf("./%s.png", data_name) , plot=p, width=9, height=8)

centrality = read.csv("closeness.csv")
centrality = centrality[1:15,]
centrality$centrality = as.numeric(as.character(centrality$centrality))
centrality$character = factor(centrality$character, levels = centrality$character[order(centrality$centrality, decreasing=FALSE)])
data_name = "closeness"
p = ggplot(centrality, aes(x=character, y=centrality, fill="#e5d5b5")) + geom_bar(stat="identity") 
p = p + ggtitle("Closeness Centrality of Marvel Characters")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + theme(axis.text=element_text(size=16,face="bold"), axis.title=element_text(size=13), axis.title.y=element_blank())
p = p + theme(plot.title = element_text(size=18,face="bold"))
p = p + ylab("Closeness Centrality Score") + guides(fill=FALSE)
p = p + coord_flip()
p = p + scale_fill_manual(values = c("#770300"))
ggsave(filename = sprintf("./%s.png", data_name) , plot=p, width=9, height=8)


################
# WORD CLOUDS
################
GenerateWordClouds <- function(character_name, data_name, color) {
  char_data = dt[grep(character_name, dt$character),]
  char_data$dialogue = gsub('\'',"",as.character(char_data$dialogue))
  char_data$dialogue = gsub('\"',"",as.character(char_data$dialogue))
  char_data$dialogue = gsub('\'s',"",as.character(char_data$dialogue))
  
  words = Corpus(VectorSource(char_data$dialogue)) 
  corpus <- tm_map(words, content_transformer(tolower))
  words = tm_map(words, stripWhitespace)
  words = tm_map(words, tolower)
  
  complete_stopwords = c(stopwords('english'), "i", "tony", "yeah", "get", "got", "dont", "youre", "thor", "steve")
  complete_stopwords = c(complete_stopwords, "gonna", "call", "know", "just", "can", "now", "come", "hes", "back")
  complete_stopwords = c(complete_stopwords, "see", "looks", "will", "need", "'s", "...", "something", "want", "like", "really")
  complete_stopwords = c(complete_stopwords, "didnt", "cant", "someone", "tell", "thats", "gonna", "well", "going", "natasha")
  # Generate wordcloud removing all stop words
  png(sprintf("%s_stopwords_wordcloud.png", data_name))
  words = tm_map(words, removeWords, complete_stopwords)
  wordcloud(words, max.words = 30, min.freq=5, random.order=FALSE, colors=brewer.pal(8,"Dark2"))
  
  dev.off()
  
  dtm = TermDocumentMatrix(words)
  m = as.matrix(dtm)
  v = sort(rowSums(m),decreasing=TRUE)
  d = data.frame(word = rownames(m), 
                 freq = rowSums(m), 
                 row.names = NULL)
  #d = data.frame(word = names(v),freq=v)
  d = d[order(d$freq, decreasing=TRUE),]
  d$word = factor(d$word, levels = d$word[order(d$freq, decreasing=TRUE)])
  
  top_words = d[1:10,]
  p = ggplot(top_words, aes(x=word, y=freq, fill=data_name)) + geom_bar(stat="identity") 
  p = p + ggtitle(sprintf("%s - Top Words", toupper(data_name)))
  p = p + theme(plot.title = element_text(hjust = 0.5))
  p = p + theme(axis.text.x=element_text(angle=90, hjust=1,face="bold"))
  p = p + theme(axis.text=element_text(size=16,face="bold"), axis.title=element_text(size=13), axis.title.x=element_blank())
  p = p + theme(plot.title = element_text(size=18,face="bold"))
  #p = p + xlab("Word")
  p = p + scale_fill_manual(values = c(color)) + guides(fill=FALSE)
  p = p + ylab("Number of Uses") 
  
  #p = p + scale_y_continuous(limits = c(0, 1200)) + scale_x_continuous(limits = c(0, 1000))
  ggsave(filename = sprintf("./%s_top10.png", data_name) , plot=p, width=4.5, height=6)
}

GenerateWordClouds("Tony Stark", "TonyStark", "red")
GenerateWordClouds("Thor", "Thor", "yellow")
GenerateWordClouds("Steve Rogers", "Steve Rogers", "blue")
GenerateWordClouds("Bruce Banner", "Bruce Banner", "green")
GenerateWordClouds("Natasha Romanov", "Natasha Romanov", "black")
GenerateWordClouds("Clint Barton", "Clint Barton", "purple")

################
# SENTIMENT
################
character_sentiments = c()
for (character in main_character_names) {
  print(character)
  character_lines = dt[dt$character == character,]
  character_sentences = unnest_tokens(character_lines, "sentences", dialogue, token = "sentences")
  character_sentiment = sentiment(character_sentences$sentences)
  character_avg_sentiment = mean(character_sentiment$sentiment)
  character_sentiments = append(character_sentiments, character_avg_sentiment)
}
sentiments = cbind(main_character_names, character_sentiments)
colnames(sentiments) = c("character", "avg_sentiment")
sentiments = data.frame(sentiments)
sentiments$avg_sentiment = as.numeric(as.character(sentiments$avg_sentiment))
sentiments$character = factor(sentiments$character, levels = sentiments$character[order(sentiments$avg_sentiment, decreasing=FALSE)])

data_name = "sentiment"
p = ggplot(sentiments, aes(x=character, y=avg_sentiment, fill="#a0dce8")) + geom_bar(stat="identity") 
p = p + ggtitle("Average Sentiment of Marvel Character")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + theme(axis.text=element_text(size=16,face="bold"), axis.title=element_text(size=13), axis.title.y=element_blank())
p = p + theme(plot.title = element_text(size=18,face="bold"))
p = p + ylab("Dialogue Sentiment") + guides(fill=FALSE)
p = p + coord_flip()
p = p + scale_fill_manual(values = c("#a0dce8"))
ggsave(filename = sprintf("./%s.png", data_name) , plot=p, width=9, height=8)

