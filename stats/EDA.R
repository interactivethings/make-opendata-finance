# Script allows to run some basic functions in order to visually explore
# the tax inequalities/disparities between the cantons

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

# read in data
data <- read.csv("data.csv", header=T,sep=",")
head(data)

summary(data)




# some handy functions
visualizeByGrossIncome <- function(gi = 100000){
  par(mfrow = c(1,1), 
      mar = c(8.2,4,4,2) + 0.1,
      oma = c(1,1,1,1))
  fac = data$gross_income == gi
  dep = data$timespan[fac]
  # plot cantonal differences
  bymedian <- reorder(data$canton[fac], -dep, median)
  boxplot(dep ~ bymedian, 
          main = 'TFD nach Kanton',
          las=2,
          cex.axis = 0.8,
          varwidth = TRUE,
  )
}

visualizeBySocialGroup <- function(sg = 1){
  par(mfrow = c(1,1), 
      mar = c(8.2,4,4,2) + 0.1,
      oma = c(1,1,1,1))
  fac = data$social_group == sg
  dep = data$timespan[fac]
  # plot cantonal differences, ordered by median
  bymedian <- reorder(data$canton[fac], -dep, median)
  boxplot(dep ~ bymedian, 
          main = 'TFD nach Kanton', 
          las=2,
          cex.axis = 0.8,
          varwidth = TRUE)
}

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
          las=2,
          cex.axis = 0.8,
          varwidth = TRUE,
          )
}
# disparity within cantons
# plot standard dev per canton
computeAovBySocialGroupAndGrossIncome <- function(sg = 1, gi = 100000){
  facsg = data$social_group == sg
  facgi = data$gross_income == gi
  fac = facsg & facgi
  dep = data$timespan[fac]
  canton_disp = aov(dep ~ data$canton[fac])
  summary(canton_disp)
}