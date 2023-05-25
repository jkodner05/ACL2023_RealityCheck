library(ggplot2)
library(dplyr)
library(wesanderson)
library(MASS)
library(lme4)
library(brms)
library(sjPlot)

data <- read.csv('~/Documents/Research/compmorph/acquisition_generalization/evaluation/summary_results/eval.tsv', header = T, sep = '\t')
data$totalCORRECT <- as.numeric(data$totalCORRECT)
data$both.featsCORRECT <- as.numeric(data$both.featsCORRECT)
data$lemma.neitherCORRECT <- as.numeric(data$lemma.neitherCORRECT)
data$bothCORRECT <- as.numeric(data$bothCORRECT)
data$lemmaCORRECT <- as.numeric(data$lemmaCORRECT)
data$featsCORRECT <- as.numeric(data$featsCORRECT)
data$neitherCORRECT <- as.numeric(data$neitherCORRECT)
data$totalTOTAL <- as.numeric(data$totalTOTAL)
data$both.featsTOTAL <- as.numeric(data$both.featsTOTAL)
data$lemma.neitherTOTAL <- as.numeric(data$lemma.neitherTOTAL)
data$bothTOTAL <- as.numeric(data$bothTOTAL)
data$lemmaTOTAL <- as.numeric(data$lemmaTOTAL)
data$featsTOTAL <- as.numeric(data$featsTOTAL)
data$neitherTOTAL <- as.numeric(data$neitherTOTAL)

summary <- data.frame(model = character(), splittype = character(), language = character(), trainsize = integer(), evaltype = character(), metric = character(), mean = double(), range = double(), std = double())

for (m in as.vector(unique(data$model))){
  for (split in as.vector(unique(data$splittype))){
    for (lg in as.vector(unique(data$language))){
      for (train_size in as.vector(unique(data$trainsize))){
        for (eval_type in as.vector(unique(data$evaltype))){
          select <- subset(data, model == m & splittype == split & language == lg & trainsize == train_size & evaltype == eval_type)
          select$totalAcc <- select$totalCORRECT / select$totalTOTAL
          select$both.featsAcc <- select$both.featsCORRECT / select$both.featsTOTAL
          select$lemma.neitherAcc <- select$lemma.neitherCORRECT / select$lemma.neitherTOTAL
          select$bothAcc <- select$bothCORRECT / select$bothTOTAL
          select$lemmaAcc <- select$lemmaCORRECT / select$lemmaTOTAL
          select$featsAcc <- select$featsCORRECT / select$featsTOTAL
          select$neitherAcc <- select$neitherCORRECT / select$neitherTOTAL
          
          select$lemma.attestedAcc <- (select$bothCORRECT + select$lemmaCORRECT) / (select$bothTOTAL + select$lemmaTOTAL)
          select$lemma.novelAcc <- (select$featsCORRECT + select$neitherCORRECT) / (select$featsTOTAL + select$neitherTOTAL)
          
          totalAve <- mean(select$totalAcc)
          totalrange <- max(select$totalAcc) - min(select$totalAcc)
          totalstd <- sd(select$totalAcc)
          totalinfo <- c(m, split, lg, train_size, eval_type, 'total', totalAve, totalrange, totalstd)
          summary[nrow(summary) + 1, ] <- totalinfo
          
          both.feats_select <- subset(select, !is.nan(select$both.featsAcc))
          if (nrow(both.feats_select) != 0){
            both.featsAve <- mean(both.feats_select$both.featsAcc)
            both.featsrange <- max(both.feats_select$both.featsAcc) - min(both.feats_select$both.featsAcc)
            both.featsstd <- sd(both.feats_select$both.featsAcc)
            both.featsinfo <- c(m, split, lg, train_size, eval_type, 'both.feats', both.featsAve, both.featsrange, both.featsstd)
            summary[nrow(summary) + 1, ] <- both.featsinfo
          }
          
          lemma.neither_select <- subset(select, !is.nan(lemma.neitherAcc))
          if (nrow(lemma.neither_select) != 0){
            lemma.neitherAve <- mean(lemma.neither_select$lemma.neitherAcc)
            lemma.neitherrange <- max(lemma.neither_select$lemma.neitherAcc) - min(lemma.neither_select$lemma.neitherAcc)
            lemma.neitherstd <- sd(lemma.neither_select$lemma.neitherAcc)
            lemma.neitherinfo <- c(m, split, lg, train_size, eval_type, 'lemma.neither', lemma.neitherAve, lemma.neitherrange, lemma.neitherstd)
            summary[nrow(summary) + 1, ] <- lemma.neitherinfo
          }
          
          both_select <- subset(select, !is.nan(bothAcc))
          if (nrow(both_select) != 0){
            bothAve <- mean(both_select$bothAcc)
            bothrange <- max(both_select$bothAcc) - min(both_select$bothAcc)
            bothstd <- sd(both_select$bothAcc)
            bothinfo <- c(m, split, lg, train_size, eval_type, 'both', bothAve, bothrange, bothstd)
            summary[nrow(summary) + 1, ] <- bothinfo
          }
          
          lemma_select <- subset(select, !is.nan(lemmaAcc))
          if (nrow(lemma_select) != 0){
            lemmaAve <- mean(lemma_select$lemmaAcc)
            lemmarange <- max(lemma_select$lemmaAcc) - min(lemma_select$lemmaAcc)
            lemmastd <- sd(lemma_select$lemmaAcc)
            lemmainfo <- c(m, split, lg, train_size, eval_type, 'lemma', lemmaAve, lemmarange, lemmastd)
            summary[nrow(summary) + 1, ] <- lemmainfo
          }
          
          feats_select <- subset(select, !is.nan(featsAcc))
          if (nrow(feats_select) != 0){
            featsAve <- mean(feats_select$featsAcc)
            featsrange <- max(feats_select$featsAcc) - min(feats_select$featsAcc)
            featsstd <- sd(feats_select$featsAcc)
            featsinfo <- c(m, split, lg, train_size, eval_type, 'feats', featsAve, featsrange, featsstd)
            summary[nrow(summary) + 1, ] <- featsinfo
          }
          
          neither_select <- subset(select, !is.nan(neitherAcc))
          if (nrow(neither_select) != 0){
            neitherAve <- mean(neither_select$neitherAcc)
            neitherrange <- max(neither_select$neitherAcc) - min(neither_select$neitherAcc)
            neitherstd <- sd(neither_select$neitherAcc)
            neitherinfo <- c(m, split, lg, train_size, eval_type, 'neither', neitherAve, neitherrange, neitherstd)
            summary[nrow(summary) + 1, ] <- neitherinfo
          }
          
          lemma.attested_select <- subset(select, !is.nan(lemma.attestedAcc))
          if (nrow(lemma.attested_select) != 0){
            lemma.attestedAve <- mean(lemma.attested_select$lemma.attestedAcc)
            lemma.attestedrange <- max(lemma.attested_select$lemma.attestedAcc) - min(lemma.attested_select$lemma.attestedAcc)
            lemma.attestedstd <- sd(lemma.attested_select$lemma.attestedAcc)
            lemma.attestedinfo <- c(m, split, lg, train_size, eval_type, 'lemma.attested', lemma.attestedAve, lemma.attestedrange, lemma.attestedstd)
            summary[nrow(summary) + 1, ] <- lemma.attestedinfo
          }
          
          lemma.novel_select <- subset(select, !is.nan(lemma.novelAcc))
          if (nrow(lemma.novel_select) != 0){
            lemma.novelAve <- mean(lemma.novel_select$lemma.novelAcc)
            lemma.novelrange <- max(lemma.novel_select$lemma.novelAcc) - min(lemma.novel_select$lemma.novelAcc)
            lemma.novelstd <- sd(lemma.novel_select$lemma.novelAcc)
            lemma.novelinfo <- c(m, split, lg, train_size, eval_type, 'lemma.novel', lemma.novelAve, lemma.novelrange, lemma.novelstd)
            summary[nrow(summary) + 1, ] <- lemma.novelinfo
          }
          
        }
      }
    }
  }
}


summary_clean <- subset(summary, evaltype == 'test')


### Table 1; see results from strategy_summaryres_bylang

## Section 5.1 Effect of Training Size

total_summary_clean <- subset(summary_clean, metric == 'total')
large_total_summary_clean <- subset(total_summary_clean, trainsize == 'large')
small_total_summary_clean <- subset(total_summary_clean, trainsize == 'small')

round((mean(as.numeric(large_total_summary_clean$mean)) - mean(as.numeric(small_total_summary_clean$mean))) * 100, 2)

ar_summary_clean <- subset(total_summary_clean, language == 'ar')

score_diff = rep(0, 12)
i = 1
for (split in as.vector(unique(ar_summary_clean$splittype))){
  for (m in as.vector(unique(ar_summary_clean$model))){
    large <- subset(ar_summary_clean, splittype == split & model == m & trainsize == 'large')
    small <- subset(ar_summary_clean, splittype == split & model == m & trainsize == 'small')
    diff <- as.numeric(large$mean) - as.numeric(small$mean)
    score_diff[i] = round(diff*100, 2)
    i = i + 1
  }
}


### Figure 2

ar <- subset(summary_clean, language == 'ar' & metric == 'total')

ar$model[ar$model == 'wuetal'] <- 'CHR-TRM'
ar$model[ar$model == 'cluzh-gr'] <- 'CLUZH-GR'
ar$model[ar$model == 'cluzh-b4'] <- 'CLUZH-B4'
ar$model[ar$model == 'nonneur'] <- 'NONNEUR'
ar$model <- factor(ar$model, levels = c('CHR-TRM', 'CLUZH-GR', 'CLUZH-B4', 'NONNEUR'))

ar$splittype[ar$splittype == 'naive_uniform'] <- 'UNIFORM'
ar$splittype[ar$splittype == 'naive_weighted'] <- 'WEIGHTED'
ar$splittype[ar$splittype == 'overlap_aware'] <- 'OVERLAPAWARE'
ar$splittype <- factor(ar$splittype, levels = c('UNIFORM', 'WEIGHTED', 'OVERLAPAWARE'))

ar %>% 
  ggplot(aes(model, round(as.numeric(mean)*100, 2), group = splittype, color = splittype)) +
  #  geom_line(aes(linetype=Length), alpha = 1) +
  #  scale_linetype_manual(values=c("dotted", 'solid', 'dotted', 'solid')) +
  geom_point(aes(color = splittype, shape = splittype), size = 1.5) + #, position=position_dodge(0.3)) +
  #  scale_shape_manual(values = c(3, 16, 3, 16)) +
  scale_color_manual(values = c("darkgreen", "steelblue", "mediumpurple4")) + 
  facet_wrap( ~ trainsize) + #, scales = "free_y") +
  #  scale_x_continuous(breaks=seq(0, 72, 6)) +
  #  scale_y_continuous(breaks=seq(0, 1300, 100)) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) + 
  theme(legend.position="top") +
  ylab("") + 
  xlab("") +
  #  guides(color = guide_legend(nrow = 2)) + 
  theme(legend.title = element_blank()) +
  scale_x_discrete(guide = guide_axis(angle = 20))




testdata = data[which(data$evaltype=="test"),]
testdata$language[testdata$language == 'ar'] <- 'Arabic'
testdata$language[testdata$language == 'de'] <- 'German'
testdata$language[testdata$language == 'en'] <- 'English'
testdata$language[testdata$language == 'es'] <- 'Spanish'
testdata$language[testdata$language == 'sw'] <- 'Swahili'
testdata$language[testdata$language == 'tr'] <- 'Turkish'

testdata$trainsize[testdata$trainsize == 'small'] <- 'Small Training'
testdata$trainsize[testdata$trainsize == 'large'] <- 'Large Training'

testdata$model[testdata$model == 'wuetal'] <- 'CHR-TRM'
testdata$model[testdata$model == 'cluzh-gr'] <- 'CLUZH-GR'
testdata$model[testdata$model == 'cluzh-b4'] <- 'CLUZH-B4'
testdata$model[testdata$model == 'nonneur'] <- 'NONNEUR'
testdata$model <- factor(testdata$model, levels = c('CHR-TRM', 'CLUZH-GR', 'CLUZH-B4', 'NONNEUR'))

testdata$splittype[testdata$splittype == 'naive_uniform'] <- 'UNIFORM'
testdata$splittype[testdata$splittype == 'naive_weighted'] <- 'WEIGHTED'
testdata$splittype[testdata$splittype == 'overlap_aware'] <- 'OVERLAPAWARE'
testdata$splittype <- factor(testdata$splittype, levels = c('UNIFORM', 'WEIGHTED', 'OVERLAPAWARE'))

testdata$acc = testdata$totalCORRECT/testdata$totalTOTAL*100
testdata$featsAttested = testdata$both.featsCORRECT/testdata$both.featsTOTAL*100
testdata$featsNovel = testdata$lemma.neitherCORRECT/testdata$lemma.neitherTOTAL*100
testdata$both = testdata$bothCORRECT/testdata$bothTOTAL*100
testdata$featsOnly = testdata$featsCORRECT/testdata$featsTOTAL*100
testdata$lemmaOnly = testdata$lemmaCORRECT/testdata$lemmaTOTAL*100
testdata$neither = testdata$neitherCORRECT/testdata$neitherTOTAL*100
meltedtest = melt(testdata, id=c("model", "splittype", "language", "seed" ,"trainsize", "evaltype", "totalCORRECT", "both.featsCORRECT", "lemma.neitherCORRECT", "bothCORRECT", "lemmaCORRECT", "featsCORRECT", "neitherCORRECT", "totalTOTAL", "both.featsTOTAL", "lemma.neitherTOTAL", "bothTOTAL", "lemmaTOTAL", "featsTOTAL", "neitherTOTAL", "acc", "featsAttested", "featsNovel"))
meltedtest = meltedtest[which(meltedtest$splittype=="OVERLAPAWARE"),]
meltedtest$variable = as.factor(meltedtest$variable)


ggplot(data=testdata, aes(model,acc)) +
  #geom_boxplot(aes(color=splittype), outlier.shape = NA) +#, position=position_identity()) +#, outlier.shape = NA) +
  #geom_point(aes(color=splittype),position = position_dodge(width = .75)) +
  #geom_point(aes(color=splittype),alpha=0.5, size=10,shape="-") +
  geom_point(aes(color=splittype),alpha=0.5, size=2) +
  facet_grid(trainsize~language) +
  ylim(0,100) +
  scale_color_manual(values = c("SteelBlue", "Goldenrod", "grey40")) + 
  theme_bw() + 
  theme(text = element_text(size=11, family="Times"),legend.text=element_text(size=11),strip.text.x = element_text(size = 12),strip.text.y = element_text(size = 12), axis.title=element_text(size=12)) + 
  theme(legend.position="top",legend.margin=margin(0,0,0,0),legend.box.margin=margin(0,0,-8,0)) +
  ylab("% Accuracy") + 
  xlab("") +
  #  guides(color = guide_legend(nrow = 2)) + 
  theme(legend.title = element_blank()) +
  scale_x_discrete(guide = guide_axis(angle = 30))
ggsave(paste("~/Documents/Research/compmorph/acquisition_generalization/evaluation/summary_results/","splittype",".pdf",sep=""),plot=last_plot(),dpi=300,width=8,height=4)



ggplot(data=meltedtest, aes(model,value)) +
  #geom_boxplot(aes(color=splittype), outlier.shape = NA) +#, position=position_identity()) +#, outlier.shape = NA) +
  #geom_point(aes(color=variable),position = position_dodge(width = .75),alpha=0.5, size=2) +
#  aes(color=variable)+
#  stat_summary(geom="point", fun="mean",size=20,shape="-") + 
  #geom_point(aes(color=variable),alpha=0.5, size=10,shape="-") +
  geom_point(aes(color=variable),alpha=0.5, size=2) +
  facet_grid(trainsize~language) +
  ylim(0,100) +
  scale_color_manual(values = c("forestgreen", "Goldenrod","darkorchid3" ,"orangered2")) + 
  #scale_fill_discrete(labels = c("A", "B")) +
  theme_bw() + 
  theme(text = element_text(size=11, family="Times"),legend.text=element_text(size=12, family="mono"),strip.text.x = element_text(size = 12),strip.text.y = element_text(size = 12), axis.title=element_text(size=12)) + 
  theme(legend.position="top",legend.margin=margin(0,0,0,0),legend.box.margin=margin(0,0,-8,0)) +
  ylab("% Accuracy") + 
  xlab("") +
  #  guides(color = guide_legend(nrow = 2)) + 
  theme(legend.title = element_blank()) +
  scale_x_discrete(guide = guide_axis(angle = 30))
ggsave(paste("~/Documents/Research/compmorph/acquisition_generalization/evaluation/summary_results/","overlaptype",".pdf",sep=""),plot=last_plot(),dpi=300,width=8,height=4)


ggplot(data=meltedtest, aes(variable,value)) +
  #geom_boxplot(aes(color=splittype), outlier.shape = NA) +#, position=position_identity()) +#, outlier.shape = NA) +
  #geom_point(aes(color=variable),position = position_dodge(width = .75),alpha=0.5, size=2) +
  geom_point(aes(color=model),alpha=0.5, size=2) +
  facet_grid(trainsize~language) +
  ylim(0,100) +
  scale_color_manual(values = c("chartreuse4", "Goldenrod","darkorchid3" ,"orangered2")) + 
  #scale_fill_discrete(labels = c("A", "B")) +
  theme_bw() + 
  theme(text = element_text(size=11, family="Times"),legend.text=element_text(size=11),strip.text.x = element_text(size = 12),strip.text.y = element_text(size = 12), axis.title=element_text(size=12)) + 
  theme(legend.position="top",legend.margin=margin(0,0,0,0),legend.box.margin=margin(0,0,-8,0)) +
  ylab("% Accuracy") + 
  xlab("") +
  #  guides(color = guide_legend(nrow = 2)) + 
  theme(legend.title = element_blank()) +
  scale_x_discrete(guide = guide_axis(angle = 30))
ggsave(paste("~/Documents/Research/compmorph/acquisition_generalization/evaluation/summary_results/","overlaptype2",".pdf",sep=""),plot=last_plot(),dpi=300,width=8,height=4)






## Section 5.2 Effect of Sampling Strategy

### Arabic

ar_uniform <- subset(summary_clean, metric == 'total' & splittype == 'naive_uniform' & language == 'ar')
ar_weighted <- subset(summary_clean, metric == 'total' & splittype == 'naive_weighted' & language == 'ar')
ar_overlap <- subset(summary_clean, metric == 'total' & splittype == 'overlap_aware' & language == 'ar')
ar_uniform_ave_large <- mean(as.numeric(subset(ar_uniform, trainsize == 'large')$mean))
ar_weighted_ave_large <- mean(as.numeric(subset(ar_weighted, trainsize == 'large')$mean))
ar_overlap_ave_large <- mean(as.numeric(subset(ar_overlap, trainsize == 'large')$mean))
ar_uniform_ave_small <- mean(as.numeric(subset(ar_uniform, trainsize == 'small')$mean))
ar_weighted_ave_small <- mean(as.numeric(subset(ar_weighted, trainsize == 'small')$mean))
ar_overlap_ave_small <- mean(as.numeric(subset(ar_overlap, trainsize == 'small')$mean))

print(round(ar_uniform_ave_large*100, 2))
print(round(ar_weighted_ave_large*100, 2))
print(round(ar_overlap_ave_large*100, 2))

print(round(ar_uniform_ave_small*100, 2))
print(round(ar_weighted_ave_small*100, 2))
print(round(ar_overlap_ave_small*100, 2))

for (lg in c('de')){
  for (split in as.vector(unique(summary_clean$splittype))){
    for (m in as.vector(unique(summary_clean$model))){
      for (train_size in c('large')){ #as.vector(unique(summary_clean$trainsize))){
        select <- subset(summary_clean, language == lg & metric == 'total' & model == m & trainsize == train_size & splittype == split)
        ave <- round(mean(as.numeric(select$mean))*100, 2)
        print(c(lg, split, m, train_size, ave)) 
      }
    }
  }
}


## 5.3 Effect of Overlap

### Arabic

for (lg in c('ar')){
  for (overlap in c('both', 'lemma', 'feats', 'neither', 'both.feats', 'lemma.neither', 'total')){
    for (train_size in c('large')){
      select <- subset(summary_clean, language == lg & metric == overlap & trainsize == train_size)
      ave <- round(mean(as.numeric(select$mean))*100, 2)
      print(c(lg, overlap,  train_size, ave))
    }
  }  
}

### Across languages

#### differences between featsAttested and featsNovel

diff_feats_attested_novel = rep(0, 6)
i = 1

for (lg in as.vector(unique(summary_clean$language))){
  for (train_size in c('small')){
    select <- subset(summary_clean, language == lg & trainsize == train_size)
    diff_feats_attested_novel[i] <- mean(as.numeric(subset(select, metric == 'both.feats')$mean)) - mean(as.numeric(subset(select, metric == 'lemma.neither')$mean))
    i = i + 1
  }  
}

round(mean(diff_feats_attested_novel) * 100, 2)

for (lg in c('ar,','de','en','es','sw','tr')){
  for (train_size in c('large','small')){
    select <- subset(summary_clean, language == lg & trainsize == train_size)
    diff = mean(as.numeric(subset(select, metric == 'both.feats')$mean)) - mean(as.numeric(subset(select, metric == 'lemma.neither')$mean))
    print(c(lg, train_size, round(diff*100, 2)))
  }  
}


#### differences between lemmaAttested and lemmaNovel

diff_lemma_attested_novel = rep(0, 6)
i = 1

for (lg in as.vector(unique(summary_clean$language))){
  for (train_size in c('large')){
    select <- subset(summary_clean, language == lg & trainsize == train_size)
    diff_lemma_attested_novel[i] <- mean(as.numeric(subset(select, metric == 'lemma.attested')$mean)) - mean(as.numeric(subset(select, metric == 'lemma.novel')$mean))
    i = i + 1
  }  
}

round(mean(diff_lemma_attested_novel) * 100, 2)

### Calculating correlation between featsAttested/lemmaAttested and proportion of featsAttested/lemmaAttested items

data$feats.attestedProp <- data$both.featsTOTAL / data$totalTOTAL
data$lemma.attestedProp <- (data$bothTOTAL + data$lemmaTOTAL) / data$totalTOTAL
data$totalAcc <- data$totalCORRECT / data$totalTOTAL
select_large <- subset(data, !is.nan(totalAcc) & trainsize == 'large' & evaltype == 'test')
select_small <- subset(data, !is.nan(totalAcc) & trainsize == 'small' & evaltype == 'test')

cor(select_large$feats.attestedProp, select_large$totalAcc, method = c('spearman'))
cor(select_small$feats.attestedProp, select_small$totalAcc, method = c('spearman'))

cor(select_large$lemma.attestedProp, select_large$totalAcc, method = c('spearman'))
cor(select_small$lemma.attestedProp, select_small$totalAcc, method = c('spearman'))

for(lang in c("ar","de","en","es","sw","tr"))
{
  print(lang)
  select_large <- subset(data, !is.nan(totalAcc) & trainsize == 'large' & evaltype == 'test' & language==lang)
  select_small <- subset(data, !is.nan(totalAcc) & trainsize == 'small' & evaltype == 'test' & language==lang)
  
  print(cor(select_large$feats.attestedProp, select_large$totalAcc, method = c('spearman')))
  print(cor(select_small$feats.attestedProp, select_small$totalAcc, method = c('spearman')))
  
  print(cor(select_large$lemma.attestedProp, select_large$totalAcc, method = c('spearman')))
  print(cor(select_small$lemma.attestedProp, select_small$totalAcc, method = c('spearman')))
}



### Calculating correlation between different evaluation metrics and overall accuracy, excluding overlapaware
naive = subset(data, splittype != "overlap_aware")
naive$feats.attestedAcc <- naive$both.featsCORRECT / naive$both.featsTOTAL
feats.attested <- subset(naive, evaltype == 'test' & !is.nan(feats.attestedAcc))
cor(as.numeric(feats.attested$feats.attestedAcc), as.numeric(feats.attested$totalAcc), method = c('spearman'))

naive$feats.novelAcc <- naive$lemma.neitherCORRECT / naive$lemma.neitherTOTAL
feats.novel <- subset(naive, evaltype == 'test' & !is.nan(feats.novelAcc))
cor(as.numeric(feats.novel$feats.novelAcc), as.numeric(feats.novel$totalAcc), method = c('spearman'))

naive$lemma.attestedAcc <- (naive$bothCORRECT + naive$lemmaCORRECT) / (naive$bothTOTAL + naive$lemmaTOTAL)
naive$lemma.novelAcc <- (naive$featsCORRECT + naive$neitherCORRECT) / (naive$featsTOTAL + naive$neitherTOTAL)
lemma.attested <- subset(naive, evaltype == 'test' & !is.nan(lemma.attestedAcc))
lemma.novel <- subset(naive, evaltype == 'test' & !is.nan(lemma.novelAcc))
cor(as.numeric(lemma.attested$lemma.attestedAcc), as.numeric(lemma.attested$totalAcc), method = c('spearman'))
cor(as.numeric(lemma.novel$lemma.novelAcc), as.numeric(lemma.novel$totalAcc), method = c('spearman'))

naive$bothAcc <- naive$bothCORRECT / naive$bothTOTAL
both <- subset(naive, evaltype == 'test' & !is.nan(bothAcc))
cor(as.numeric(both$bothAcc), as.numeric(both$totalAcc), method = c('spearman'))

naive$featsAcc <- naive$featsCORRECT / naive$featsTOTAL
feats <- subset(naive, evaltype == 'test' & !is.nan(featsAcc))
cor(as.numeric(feats$featsAcc), as.numeric(feats$totalAcc), method = c('spearman'))

naive$lemmaAcc <- naive$lemmaCORRECT / naive$lemmaTOTAL
lemma <- subset(naive, evaltype == 'test' & !is.nan(lemmaAcc))
cor(as.numeric(lemma$lemmaAcc), as.numeric(lemma$totalAcc), method = c('spearman'))

naive$neitherAcc <- naive$neitherCORRECT / naive$neitherTOTAL
neither <- subset(naive, evaltype == 'test' & !is.nan(neitherAcc))
cor(as.numeric(neither$neitherAcc), as.numeric(neither$totalAcc), method = c('spearman'))



aware = subset(data, splittype == "overlap_aware")
aware$feats.attestedAcc <- aware$both.featsCORRECT / aware$both.featsTOTAL
feats.attested <- subset(aware, evaltype == 'test' & !is.nan(feats.attestedAcc))
cor(as.numeric(feats.attested$feats.attestedAcc), as.numeric(feats.attested$totalAcc), method = c('spearman'))

aware$feats.novelAcc <- aware$lemma.neitherCORRECT / aware$lemma.neitherTOTAL
feats.novel <- subset(aware, evaltype == 'test' & !is.nan(feats.novelAcc))
cor(as.numeric(feats.novel$feats.novelAcc), as.numeric(feats.novel$totalAcc), method = c('spearman'))

aware$lemma.attestedAcc <- (aware$bothCORRECT + aware$lemmaCORRECT) / (aware$bothTOTAL + aware$lemmaTOTAL)
aware$lemma.novelAcc <- (aware$featsCORRECT + aware$neitherCORRECT) / (aware$featsTOTAL + aware$neitherTOTAL)
lemma.attested <- subset(aware, evaltype == 'test' & !is.nan(lemma.attestedAcc))
lemma.novel <- subset(aware, evaltype == 'test' & !is.nan(lemma.novelAcc))
cor(as.numeric(lemma.attested$lemma.attestedAcc), as.numeric(lemma.attested$totalAcc), method = c('spearman'))
cor(as.numeric(lemma.novel$lemma.novelAcc), as.numeric(lemma.novel$totalAcc), method = c('spearman'))

aware$bothAcc <- aware$bothCORRECT / aware$bothTOTAL
both <- subset(aware, evaltype == 'test' & !is.nan(bothAcc))
cor(as.numeric(both$bothAcc), as.numeric(both$totalAcc), method = c('spearman'))

aware$featsAcc <- aware$featsCORRECT / aware$featsTOTAL
feats <- subset(aware, evaltype == 'test' & !is.nan(featsAcc))
cor(as.numeric(feats$featsAcc), as.numeric(feats$totalAcc), method = c('spearman'))

aware$lemmaAcc <- aware$lemmaCORRECT / aware$lemmaTOTAL
lemma <- subset(aware, evaltype == 'test' & !is.nan(lemmaAcc))
cor(as.numeric(lemma$lemmaAcc), as.numeric(lemma$totalAcc), method = c('spearman'))

aware$neitherAcc <- aware$neitherCORRECT / aware$neitherTOTAL
neither <- subset(aware, evaltype == 'test' & !is.nan(neitherAcc))
cor(as.numeric(neither$neitherAcc), as.numeric(neither$totalAcc), method = c('spearman'))




### Calculating correlation between different evaluation metrics 
for(testtype in c("small","large")){
  testdata = subset(data, trainsize == testtype)
testdata$feats.attestedAcc <- testdata$both.featsCORRECT / testdata$both.featsTOTAL
testdata$feats.novelAcc <- testdata$lemma.neitherCORRECT / testdata$lemma.neitherTOTAL
feats.attested <- subset(testdata, evaltype == 'test' & !is.nan(feats.attestedAcc) & !is.nan(feats.novelAcc))
feats.novel <- subset(testdata, evaltype == 'test' & !is.nan(feats.novelAcc) & !is.nan(feats.attestedAcc))

testdata$lemma.attestedAcc <- (testdata$bothCORRECT + testdata$lemmaCORRECT) / (testdata$bothTOTAL + testdata$lemmaTOTAL)
testdata$lemma.novelAcc <- (testdata$featsCORRECT + testdata$neitherCORRECT) / (testdata$featsTOTAL + testdata$neitherTOTAL)
lemma.attested <- subset(testdata, evaltype == 'test' & !is.nan(lemma.attestedAcc) & !is.nan(lemma.novelAcc))
lemma.novel <- subset(testdata, evaltype == 'test' & !is.nan(lemma.novelAcc) & !is.nan(lemma.attestedAcc))

testdata$bothAcc <- testdata$bothCORRECT / testdata$bothTOTAL
testdata$not_bothAcc = (testdata$totalCORRECT - testdata$bothCORRECT) / (testdata$totalTOTAL - testdata$bothTOTAL)
both <- subset(testdata, evaltype == 'test' & !is.nan(bothAcc) & !is.nan(not_bothAcc))
not_both = subset(testdata, evaltype == 'test' & !is.nan(not_bothAcc) & !is.nan(bothAcc))
testdata$featsAcc <- testdata$featsCORRECT / testdata$featsTOTAL
testdata$not_featsAcc = (testdata$totalCORRECT - testdata$featsCORRECT) / (testdata$totalTOTAL - testdata$featsTOTAL)
feats <- subset(testdata, evaltype == 'test' & !is.nan(featsAcc) & !is.nan(not_featsAcc))
not_feats = subset(testdata, evaltype == 'test' & !is.nan(not_featsAcc) & !is.nan(featsAcc))
testdata$lemmaAcc <- testdata$lemmaCORRECT / testdata$lemmaTOTAL
testdata$not_lemmaAcc = (testdata$totalCORRECT - testdata$lemmaCORRECT) / (testdata$totalTOTAL - testdata$lemmaTOTAL)
lemma <- subset(testdata, evaltype == 'test' & !is.nan(lemmaAcc) & !is.nan(not_lemmaAcc))
not_lemma = subset(testdata, evaltype == 'test' & !is.nan(not_lemmaAcc) & !is.nan(lemmaAcc))
testdata$neitherAcc <- testdata$neitherCORRECT / testdata$neitherTOTAL
testdata$not_neitherAcc = (testdata$totalCORRECT - testdata$neitherCORRECT) / (testdata$totalTOTAL - testdata$neitherTOTAL)
neither <- subset(testdata, evaltype == 'test' & !is.nan(neitherAcc) & !is.nan(not_neitherAcc))
not_neither = subset(testdata, evaltype == 'test' & !is.nan(not_neitherAcc) & !is.nan(neitherAcc))


print(cor(as.numeric(feats.attested$feats.attestedAcc), as.numeric(feats.novel$feats.novelAcc), method = c('spearman')))
plot(lemma.attested$feats.attestedAcc~lemma.novel$feats.novelAcc)
print(cor(as.numeric(lemma.attested$lemma.attestedAcc), as.numeric(lemma.novel$lemma.novelAcc), method = c('spearman')))
plot(lemma.attested$lemma.attestedAcc~lemma.novel$lemma.novelAcc)

print(cor(as.numeric(both$bothAcc), as.numeric(not_both$not_bothAcc), method = c('spearman')))

print(cor(as.numeric(feats$featsAcc), as.numeric(not_feats$not_featsAcc), method = c('spearman')))

print(cor(as.numeric(lemma$lemmaAcc), as.numeric(not_lemma$not_lemmaAcc), method = c('spearman')))

print(cor(as.numeric(neither$neitherAcc), as.numeric(not_neither$not_neitherAcc), method = c('spearman')))
}



## Section 5.4 Model Ranking

### Figure 3

ar <- subset(summary_clean, language == 'ar' & metric == 'total')

ar$model[ar$model == 'wuetal'] <- 'CHR-TRM'
ar$model[ar$model == 'cluzh-gr'] <- 'CLUZH-GR'
ar$model[ar$model == 'cluzh-b4'] <- 'CLUZH-B4'
ar$model[ar$model == 'nonneur'] <- 'NONNEUR'
ar$model <- factor(ar$model, levels = c('CHR-TRM', 'CLUZH-GR', 'CLUZH-B4', 'NONNEUR'))

ar$splittype[ar$splittype == 'naive_uniform'] <- 'UNIFORM'
ar$splittype[ar$splittype == 'naive_weighted'] <- 'WEIGHTED'
ar$splittype[ar$splittype == 'overlap_aware'] <- 'OVERLAPAWARE'
ar$splittype <- factor(ar$splittype, levels = c('UNIFORM', 'WEIGHTED', 'OVERLAPAWARE'))

ar %>% 
  ggplot(aes(splittype, round(as.numeric(mean)*100, 2), group = trainsize, color = trainsize)) +
  #  geom_line(aes(linetype=Length), alpha = 1) +
  #  scale_linetype_manual(values=c("dotted", 'solid', 'dotted', 'solid')) +
  geom_point(aes(color = trainsize, shape = trainsize), size = 1.5) + #, position=position_dodge(0.3)) +
  #  scale_shape_manual(values = c(3, 16, 3, 16)) +
  scale_color_manual(values = c("darkgreen", "steelblue")) + 
  facet_wrap( ~ model) + #, scales = "free_y") +
  #  scale_x_continuous(breaks=seq(0, 72, 6)) +
  #  scale_y_continuous(breaks=seq(0, 1300, 100)) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) + 
  theme(legend.position="top") +
  ylab("") + 
  xlab("") +
  #  guides(color = guide_legend(nrow = 2)) + 
  theme(legend.title = element_blank()) +
  scale_x_discrete(guide = guide_axis(angle = 10))


### Average across languages

for (m in as.vector(unique(summary_clean$model))){
  for (train_size in c('small', 'large')){
    select <- subset(summary_clean, model == m & trainsize == train_size & metric == 'total')
    ave = mean(as.numeric(select$mean))
    print(c(m, train_size, ave)) 
  }
}

### Specific language

for (m in as.vector(unique(summary_clean$model))){
  for (train_size in c('small', 'large')){
    select <- subset(summary_clean, model == m & trainsize == train_size & metric == 'total' & language == 'es')
    ave = mean(as.numeric(select$mean))
    print(c(m, train_size, ave)) 
  }
}


### Section 5.5. Variation between Random Seeds


for (lg in as.vector(unique(summary_clean$language))){
  for (train_size in as.vector(unique(summary_clean$trainsize))){
    select <- subset(summary_clean, metric == 'total' & language == lg & trainsize == train_size)
    ave_range <- round(mean(as.numeric(select$range))*100,2)
    range_range <- round(max(as.numeric(select$range))*100,2) - round(min(as.numeric(select$range))*100,2)
    ave_std <- round(mean(as.numeric(select$std))*100,2)
    range_std <- round(max(as.numeric(select$std))*100,2) - round(min(as.numeric(select$std))*100,2)
    print(c(lg, train_size, ave_range, range_range, ave_std, range_std))
  }
}

for (split in as.vector(unique(summary_clean$splittype))){
  for (train_size in as.vector(unique(summary_clean$trainsize))){
    select <- subset(summary_clean, metric == 'total' & splittype == split & trainsize == train_size)
    ave_range <- round(mean(as.numeric(select$range))*100,2)
    range_range <- round(max(as.numeric(select$range))*100,2) - round(min(as.numeric(select$range))*100,2)
    ave_std <- round(mean(as.numeric(select$std))*100,2)
    range_std <- round(max(as.numeric(select$std))*100,2) - round(min(as.numeric(select$std))*100,2)
    print(c(split, train_size, ave_range, range_range, ave_std, range_std))
  }
}


for (m in as.vector(unique(summary_clean$model))){
  for (train_size in as.vector(unique(summary_clean$trainsize))){
    select <- subset(summary_clean, metric == 'total' & model == m & trainsize == train_size)
    ave_range <- round(mean(as.numeric(select$range))*100,2)
    range_range <- round(max(as.numeric(select$range))*100,2) - round(min(as.numeric(select$range))*100,2)
    ave_std <- round(mean(as.numeric(select$std))*100,2)
    range_std <- round(max(as.numeric(select$std))*100,2) - round(min(as.numeric(select$std))*100,2)
    print(c(m, train_size, ave_range, range_range, ave_std, range_std))
  }
}

## Appendix

### Table 8

strategy_summaryres_bymodel <- data.frame(splittype = character(), model = character(), trainsize = integer(), metric = character(), mean = double(), std = double())

for (split in as.vector(unique(summary_clean$splittype))){
  for (train_size in as.vector(unique(summary_clean$trainsize))){
    for (overlap in c('both', 'lemma', 'feats', 'neither', 'both.feats', 'lemma.neither', 'total')){
      for (m in as.vector(unique(summary_clean$model))){  
        select <- subset(summary_clean, splittype == split & model == m & trainsize == train_size & metric == overlap)
        score_mean <- mean(as.numeric(select$mean))
        score_std <- sd(as.numeric(select$mean))
        info <- c(split, m, train_size, overlap, round(score_mean*100, 2), round(score_std*100, 2))
        strategy_summaryres_bymodel[nrow(strategy_summaryres_bymodel) + 1, ] <- info 
      }
    }
  }
}

write.csv(strategy_summaryres_bymodel, 'strategy_summaryres_bymodel.csv')


### Table 9

strategy_summaryres_bylang <- data.frame(splittype = character(), language = character(), trainsize = integer(), metric = character(), mean = double(), std = double())

for (split in as.vector(unique(summary_clean$splittype))){
  for (train_size in as.vector(unique(summary_clean$trainsize))){
    for (overlap in c('both', 'lemma', 'feats', 'neither', 'both.feats', 'lemma.neither', 'total')){
      select <- subset(summary_clean, splittype == split & trainsize == train_size & metric == overlap)
      score_mean <- mean(as.numeric(select$mean))
      score_std <- sd(as.numeric(select$mean))
      info <- c(split, 'overall', train_size, overlap, round(score_mean*100, 2), round(score_std*100, 2))
      strategy_summaryres_bylang[nrow(strategy_summaryres_bylang) + 1, ] <- info 
      
      for (lg in as.vector(unique(summary_clean$language))){  
        select <- subset(summary_clean, splittype == split & language == lg & trainsize == train_size & metric == overlap)
        score_mean <- mean(as.numeric(select$mean))
        score_std <- sd(as.numeric(select$mean))
        info <- c(split, lg, train_size, overlap, round(score_mean*100, 2), round(score_std*100, 2))
        strategy_summaryres_bylang[nrow(strategy_summaryres_bylang) + 1, ] <- info 
      }
    }
  }
}

write.csv(strategy_summaryres_bylang, 'strategy_summaryres_bylang.csv')



