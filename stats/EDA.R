# Script allows to run some basic functions in order to visually explore
# the tax inequalities/disparities between the cantons

# in particular, visualizeBySocialGroupAndGrossIncome(social group, gross income) lets you visualize
# the cantonal disparities with social group and gross income held constant
# usage example: visualizeBySocialGroupAndGrossIncome(1,20000) visualizes disparities for social group "ledig"
# and gross income 20'000 CHF

# define a social group dictionary
# timespan by social group
# 1: ledig
# 2: verheiratet ohne kind
# 3: verheiratet mit kind
# 4: rentner
sg_dictionary <- data.frame(index = c(1,2,3,4),
                            value = c('Ledig', 
                                      'Verheiratet (ohne Kinder)',
                                      'Verheiratet (mit Kinder)',
                                      'Pensioniert')
                            )

# define a gross income dictionary
gi_dictionary <- data.frame(index = levels(as.factor(data$gross_income)))

# read in data
data <- read.csv("data.csv", header=T,sep=",", , encoding="latin1")

# basic visualization
#################################################################33333
# visualize data with social group and gross income held constant
#
visualizeBySocialGroupAndGrossIncome <- function(sg =1, gi = 100000){
  par(mfrow = c(1,1), 
      mar = c(8.2,4,4,2) + 0.1,
      oma = c(1,1,1,1))
  facsg = data$social_group == sg
  facgi = data$gross_income == gi
  fac = facsg & facgi
  dep = data$timespan[fac]
   # plot cantonal differences
  # plot cantonal differences, ordered by median
  bymedian <- reorder(data$canton[fac], -dep, median)
  boxplot(dep ~ bymedian, 
          main = 'TFD nach Kanton',
          ylab = 'Tage bis Einkommenssteuern bezahlt sind',
          las=2,
          cex.axis = 0.8,
          varwidth = TRUE,
          )
  mtext(paste('Zivilstand:',
              sg_dictionary$value[sg_dictionary$index == sg],
              ', Einkommen:',
              format(gi, scientific=F),
              'CHF'))
}

# disparity between cantons (using anova)
##############################################################
# uses anova (F-statistic) to compute an indicator of cantonal disparities
# gross income and social group are held constant
#
# returns F-stat (the higher the more disparities for this particular combination
# of gross income and social group)
computeAovBySocialGroupAndGrossIncome <- function(sg = 1, gi = 100000){
  facsg = data$social_group == sg
  facgi = data$gross_income == gi
  fac = facsg & facgi
  dep = data$timespan[fac]
  canton_disp = summary(aov(dep ~ data$canton[fac]))
  canton_disp[[1]]$'F value'[1]
}

# uses computeAovBySocialGroupAndGrossIncome to find the combination of social group
# and income class with the highest cantonal disparities
# 
# returns f-stat, social group and gross income for largest disparity as a list
computeLargestDisparity <- function(){
  max_f <- 0
  max_sg <- 1
  max_gi <- 20000
  for(sg in sg_dictionary$index){
    for(gi in gi_dictionary$index){
      f <- computeAovBySocialGroupAndGrossIncome(sg, gi)
      if(f >  max_f){
        max_f <- f
        max_sg <- sg
        max_gi <- gi
      }
    }
  }
  out <- list(f=max_f, sg=max_sg, gi=max_gi)
  out
}

# disparity within cantons (using range)
##############################################################
# finds the canton where the range between the lowest community
# and the highest community (fewest days,most days) is widest
# for a given combination of social group and gross income

# returns range and canton as a list
computeRangeBySocialGroupAndGrossIncome <- function(sg = 1, gi = 100000){
  n <- 26
  facsg = data$social_group == sg
  facgi = data$gross_income == gi
  fac = facsg & facgi
  dep = data$timespan
  max_range <- 0
  max_canton <- ""
  for(i in levels(as.factor(data$canton))){
    cantonal_range <- range(data$timespan[data$canton == i & fac])
    cantonal_range <- max(cantonal_range) - min(cantonal_range)
    if(cantonal_range > max_range){
      max_range <- cantonal_range
      max_canton <- i
    }
  }
  out <- list(max=max_range, canton=max_canton)
  print(out)
  out
}

# uses computeRangeBySocialGroupAndGrossIncome to find the canton with
# the widest range (as defined above) in all possible combinations
# of social groups and gross income
# 
# returns the range, the name of the canton, social group
# and gross income for widest range as a list
computeLargestRange <- function(){
  max_r <- 0
  max_sg <- 1
  max_gi <- 20000
  for(sg in sg_dictionary$index){
    for(gi in gi_dictionary$index){
      r <- computeRangeBySocialGroupAndGrossIncome(sg, gi)
      if(r$max >  max_r){
        max_r <- r$max
        max_canton <- r$canton
        max_sg <- sg
        max_gi <- gi
      }
    }
  }
  out <- list(max_range=max_r, canton=max_canton, sg=max_sg, gi=max_gi)
  out
}

# visualize largest disparity
out <- computeLargestDisparity()
visualizeBySocialGroupAndGrossIncome(out[2],out[3])

# visualize largest range
out <- computeLargestRange()
visualizeBySocialGroupAndGrossIncome(1,1000000)