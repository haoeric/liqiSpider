setwd("~/GitProject/liqiSpider")
d <- read.csv("liqi.csv", header = TRUE, stringsAsFactors = FALSE)
s <- read.table("sources.txt", stringsAsFactors = FALSE, header = FALSE)[,1]

for(i in seq_len(nrow(d))){
    cat(i)
    if(!(d$title[i] == "")){
        cat("-processing...")
        tools <- strsplit(d$tools[i], ";", fixed = TRUE)[[1]]
        cat(length(tools), "...")
        links <- strsplit(d$links[i], ";", fixed = TRUE)[[1]]
        cat(length(links), "...")
        
        if(length(tools) != length(links)){
            cat("Not all tools has a corresponding link!")
            if(length(tools) < length(links)){
                links <- links[1:length(tools)]
            }else{
                links <- rep(links, length.out = length(tools))
            }
        }
        
        ## remove dumplicate tools from same author
        unt <- unique(tools)
        uid <- match(unt, tools)
        tools <- tools[uid]
        links <- links[uid]
        
        if(grepl("利器访谈｜", d$title[i], fixed = TRUE)){
            dti <- sub("利器访谈｜", "", d$title[i], fixed = TRUE)
            author <- strsplit(dti, "，", fixed = TRUE)[[1]][1]
            profession <- strsplit(dti, "，", fixed = TRUE)[[1]][2]
        }else{
            if(grepl("｜", d$title[i], fixed = TRUE)){
                author <- strsplit(d$title[i], "｜", fixed = TRUE)[[1]][1]
                profession <- strsplit(d$title[i], "｜", fixed = TRUE)[[1]][2]
            }else if(grepl(" | ", d$title[i], fixed = TRUE)){
                author <- strsplit(d$title[i], " | ", fixed = TRUE)[[1]][1]
                profession <- strsplit(d$title[i], " | ", fixed = TRUE)[[1]][2]
            }
        }
        cat(author)
        
        ## remove white space in either head or tail
        tools <- gsub("^\\s+", "", tools)
        tools <- gsub("\\s+$", "", tools)
        links <- gsub("^\\s+", "", links)
        links <- gsub("\\s+$", "", links)
        author <- gsub("^\\s+", "", author)
        author <- gsub("\\s+$", "", author)
        profession <- gsub("^\\s+", "", profession)
        profession <- gsub("\\s+$", "", profession)
        
        date <- as.Date(gsub("\\-$", "", gsub("\\D", "-", d$date[i])))
        
        dfi <- data.frame(author = rep(author, length(tools)),
                          profession = rep(profession, length(tools)),
                          tools = tools,
                          links = links,
                          date = rep(date, length(tools)),
                          source = rep(s[i], length(tools)))
        
        if(i == 1){
            df <- dfi
        }else{
            df <- rbind(df, dfi)
        }
    }
    cat("\n")
}

write.csv(df, file="liqi_data_tidy.csv")

## filter liqi home links

dfn <- df[df$tools != "利器社群" & 
              df$tools != "赞助" & 
              df$tools != "http://liqi.io/community", ]
dfn$links <- gsub(" 翻$", "", dfn$links)

library(dplyr)

## 分享达人榜单
fxdr <- dfn %>% 
    group_by(author) %>%
    summarise(toolCounts = n(), source = unique(source)) %>%
    arrange(desc(toolCounts)) 

View(fxdr)


## 利器排行

lqph <- dfn %>% 
    group_by(tools) %>%
    summarise(toolCounts = n(), link = links[1], source = source[1]) %>%
    arrange(desc(toolCounts)) 
    
View(lqph)


