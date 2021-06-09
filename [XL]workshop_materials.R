##--------Basic Exercises--------##

#### object class used: vector, list, matrix
#### function used: rnorm, runif, round, print, summary, mean, median, min, max, sd, var, sum, length, cbind, rbind, rownames, colnames, dim

#--------the vector part--------#

## Generate Data

# set the seed to the random number generation to be 1. This ensures the results 
# are reproducible across everyone's execution
set.seed(1) 
# height(cm) of 50 males and 50 females(estimated from https://dqydj.com/height-percentile-calculator-for-men-and-women/)
male_height = rnorm(n = 50, mean = 175.6, sd = 11)
female_height = rnorm(n = 50, mean = 161.5, sd = 10.5)
# keep only two decimal places
male_height = round(male_height, 2)
female_height = round(female_height, 2)
# see the heights in each group
print(male_height)
print(female_height)

## Get Basic Information about the Data

# get minimum, maximum and quantiles using one function
summary(male_height)
summary(female_height)
# get only mean
mean(male_height)
mean(female_height)
# get only median
median(male_height)
median(female_height)
# get only minimum
min(male_height)
min(female_height)
# get only maximum
max(male_height)
max(female_height)
# get standard deviation
sd(male_height)
sd(female_height)
# get variance
var(male_height)
var(female_height)
# get sum of height
sum(male_height)
sum(female_height)
# get the numbers of data in each group
length(male_height)
length(female_height)

#--------the list part--------#

## Generate Data

# If we have another record about weight for the same group of people, we can 
# put weight and height data together using list(assuming weight has correlation with height)
set.seed(1)
# generate data about weight(kg)
male_weight = 0.52*male_height + runif(n = 50, min = -15, max = 15)
male_weight = round(male_weight, 2)
female_weight = 0.48*female_height + runif(n = 50, min = -14, max = 14)
female_weight = round(female_weight, 2)
# put weight data and height data together
male_group = list(height = male_height, weight = male_weight)
female_group = list(height = female_height, weight = female_weight)
# see what this data looks like
print(male_group)
print(female_group)

## Access Data

# access the first element of the `male group` list.
print(male_group[1])
# access the `height` element(which is the first element) of the `male group` list.
print(male_group$height)

#--------the matrix part--------#

## Generate Data

# simulate a gene expression data set consisting of 10 samples (5 from disease 
# cases and 5 from healthy controls) and 50 genes (5 up-regulated in disease, 5 
# down-regulated in disease, 40 not differentially regulated)
set.seed(1)
# generate the expression of five genes that are up-regulated in the disease group compared to the control group
gene_exp.up <- cbind( matrix( rnorm(25, 9, 0.3), 5, 5), matrix( rnorm(25, 7, 0.3), 5, 5) ) 
# generate the expression of five genes that are down-regulated in the disease group compared to the control group
gene_exp.down <- cbind( matrix( rnorm(25, 7, 0.3), 5, 5), matrix( rnorm(25, 9, 0.3), 5, 5) )
# generate the expression of 40 genes that do not have differential expression across the 10 samples regardless of sample grouping
gene_exp.others <- matrix( rnorm(400, 8, 0.3), 40, 10)
# combine genes generated above to a combined data matrix consisting of 50 genes and 10 samples
gene_exp<-rbind(gene_exp.up, gene_exp.down, gene_exp.others)
# print the dimension of the matrix (50 rows and 10 columns)
dim(gene_exp)
# add a name to each row (Gene1, Gene2, ..., Gene50)
rownames(gene_exp) <- paste("Gene", 1:50, sep="")
# add a name to each column (Sample1, Sample2, Sample3,...Sample10)
colnames(gene_exp) <- paste("Sample", 1:10, sep="")

##--------Intermediate Exercises--------##

#### object class used: vector, list, matrix
#### function used: cor, t.test, fisher.test, if.else

## Some Basic Tests

# 1. correlation: check the correlation between height and weight in male group 
# and female group
cor(male_group$height, male_group$weight)
cor(female_group$height, female_group$weight)

# 2. t.test: test if there is a significant difference between the means of 
# height&weight in the male group and female group
t.test(male_group$height, female_group$height)
t.test(male_group$weight, female_group$weight)

# 3. fisher.test: test the proportions of people with obesity in male group and 
# female group have significant difference or not
# 3-1 calculate BMI using equation BMI = weight(kg)/height(m)^2
male_BMI = male_group$weight/(male_group$height/100)^2
female_BMI = female_group$weight/(female_group$height/100)^2
# 3-2 for people with BMI equal or larger than 30, define them as having obesity
male_obesity = ifelse(male_BMI >= 30, "Yes", "No")
female_obesity = ifelse(female_BMI >= 30, "Yes", "No")
# 3-3 get the number of people with obesity in each group and summary in a matrix
male_num = table(male_obesity)
female_num = table(female_obesity)
obesity_num = rbind(male_table, female_table)
# 3-4 fisher's exact test
fisher.test(obesity_num)
