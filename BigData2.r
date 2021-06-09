





### Identify genes that are differentially expressed between disease vs. control 

# In this example, we know sample 1-5 belong to the 'disease' group, and sample 6-10 belong to the 'control group'
res<-apply(dd, 1, function(x){    # This operation go through every row (dimension 1), and call the numerical vector in that row 'x'
  r<-t.test(x[1:5], x[6:10], alternative="two.sided", paried=F);   # This operation performs a unpaired, two-sided T test 
  dif<-mean(x[1:5]) - mean(x[6:10])       # This calcualte the difference of the two group means. If the values are in the log scale, this is also called the log fold change
  return( c("Difference"=dif, "p"=r$p.value) )   # Two values are returned for each gene (e.g., row). The first value is the difference of group means and the second value is the p-value generated by the t-test
})


hist(res["p",], xlab="P values", ylab="Frequency", col="grey", main="Distribution of p values")  # This displays the distribution of T test p-value of the 50 genes (i.e., 50 tests) as a histogram
# In this plot, we observe an enrichment of small p-values (values close to zero). If the data is entirely randomly generated, we expect to see a plot that are flat.

plot(res["Difference",],res["p",], xlab="Difference of group means", ylab="p value", main="Relationship between p-value and difference of group means", pch=16, cex=1.5, col="grey", bty="none")

plot(res["Difference",], -log10(res["p",]), xlab="Difference of group means", ylab="-log10(p value)", main="Volcano plot", pch=16, cex=1.5, col="grey", bty="none")
abline(h = -log10(0.05), lty=2);
abline(v = c(-1, 1), lty=2);

fdr<-p.adjust(res["p",],method="fdr"); # This operation performs a multiple testing correction. We used the 'false discovery rate' (fdr) method. 

plot(res["Difference",], -log10(fdr), xlab="Difference of group means", ylab="-log10(p value)", main="Volcano plot with FDR", pch=16, cex=1.5, col="grey", bty="none")
abline(h = -log10(0.05), lty=2);
abline(v = c(-1, 1), lty=2);

plot(res["p",],fdr, xlab="p-value", ylab="FDR", xlim=c(0,1), ylim=c(0,1), pch=16, col="grey", bty="n", cex=2)
lines(c(0,1),c(0,1),lty=2)





### Identify genes that have high gene expression variability across all samples (regardless of disease grouping)
v <- apply(dd, 1, var); # This operation calculate the variance of each gene (e.g., each row, which is dimension 1). 

barplot(v, las=2); # It can be seen that   

topK <- 10;
ind.highV <- order(v, decreasing=T)[1:topK];

heatmap(dd[ind.highV,], scale="none", main=paste("Top ", topK, " most variably expressed genes", sep=""));

### Calculate correlation between every pairs of highly variably expressed genes
cor.features<-cor( t(dd[ind.highV,]), method="pearson"); # Calculate a (Pearson) correlation coefficient for every pair of highly variable genes 
heatmap(cor.features, scale="none", main="Correlation among features"); # A heatmap visualising the correlation matrix




###
# Extra bonus: why do I need to do multiple testing correction?
###
set.seed(0)
dd.random<-matrix(rnorm(5000,7,0.5),500,10);

res.random<-apply(dd.random, 1, function(x){    # This operation go through every row (dimension 1), and call the numerical vector in that row 'x'
  r<-t.test(x[1:5], x[6:10], alternative="two.sided", paried=F);   # This operation performs a unpaired, two-sided T test 
  r$p.value; # Returns only the p-value  
})
hist(res.random, xlab="P values", ylab="Frequency", col="grey", main="If data are entirely randomly generated")  # This displays the distribution of T test p-value of the 50 genes (i.e., 50 tests) as a histogram

fdr.random<-p.adjust(res.random,method="fdr"); # Estimate false discovery rate
plot(res.random, fdr.random, xlab="p-value", ylab="FDR", xlim=c(0,1), ylim=c(0,1), pch=16, col="grey", bty="n", cex=2)
lines(c(0,1),c(0,1),lty=2)




















############################################################################
# Building a supervised machine learning model (classifier)
############################################################################








# This install the 'caret' package and its dependent packages...this may take a while
install.packages("caret", dependencies=c("Depends","Imports"))

# This loads the 'caret' package
library(caret)


### Simulate a gene expression data set consisting of 100 samples (50 from disease cases and 50 from healthy controls) and 50 genes (5 up-regulated in disease, 5 down-regulated in disease, 40 not differentially regulated)
set.seed(1); #This operation set the seed to the random number generation to be 1. This ensures the results are reproducible across everyone's execution
dd.up <- cbind( matrix( rnorm(250, 9, 2.5), 5, 50), matrix( rnorm(250, 7, 2.5), 5, 50) )  # This generates the expression of five genes that are up-regulated in the disease group compared to the control group
dd.down <- cbind( matrix( rnorm(250, 7, 2.5), 5, 50), matrix( rnorm(250, 9, 2.5), 5, 50) ) # This generates the expression of five genes that are down-regulated in the disease group compared to the control group
dd.others <- matrix( rnorm(4000, 8, 2.5), 40, 100); # This generates the expression of 40 genes that do not hvae differential expression across the 10 samples regardless of sample grouping
dd<-rbind(dd.up, dd.down, dd.others);  # This is the combined data matrix consisting of 50 genes and 10 samples

dim(dd); ### This show the dimension of the matrix (50 rows and 100 columns)
rownames(dd) <- paste("Gene", 1:50, sep=""); # This operation add a name to each row (Gene1, Gene2, ..., Gene50)
colnames(dd) <- paste("Sample", 1:100, sep=""); # This operation add a name to each column (Sample1, Sample2, Sample3,...Sample10)

### Add the 'label' to the data. The data matrix needs to be transposed since this is the required format for the caret package 
labels<-c(rep("Disease",50), rep("Control",50));
print(labels);
dd.frame<-data.frame(t(dd),labels)

dd.frame[1:3,]


## Training and evaluation
control <- trainControl(method="cv", number=5);   # This is 5-fold cross-validation

fit.svm <- train(labels~., data=dd.frame, method="svmRadial", trControl=control)  # This operation trains an SVM classifier
fit.knn <- train(labels~., data=dd.frame, method="knn",  trControl=control)   # This operation trains a k-NN classifier   



### We will generate some new data for testing 50 features, 40 samples - 20 disease, 20 controls)
set.seed(21); #This operation set the seed to the random number generation to be 1. This ensures the results are reproducible across everyone's execution
dd.test.up <- cbind( matrix( rnorm(100, 9, 2.5), 5, 20), matrix( rnorm(100, 7, 2.5), 5, 20) )  # This generates the expression of five genes that are up-regulated in the disease group compared to the control group
dd.test.down <- cbind( matrix( rnorm(100, 7, 2.5), 5, 20), matrix( rnorm(100, 9, 2.5), 5, 20) ) # This generates the expression of five genes that are down-regulated in the disease group compared to the control group
dd.test.others <- matrix( rnorm(1600, 8, 2.5), 40, 40); # This generates the expression of 40 genes that do not hvae differential expression across the 10 samples regardless of sample grouping
dd.test<-rbind(dd.test.up, dd.test.down, dd.test.others);  # This is the combined data matrix consisting of 50 genes and 10 samples

dim(dd.test); ### This show the dimension of the matrix (50 rows and 100 columns)
rownames(dd.test) <- paste("Gene", 1:50, sep=""); # This operation add a name to each row (Gene1, Gene2, ..., Gene50)
colnames(dd.test) <- paste("Sample", 1:40, sep=""); # This operation add a name to each column (Sample1, Sample2, Sample3,...Sample10)

labels.test <- c(rep("Disease",20), rep("Control",20))
dd.test.frame<-data.frame(t(dd.test),"label"= labels.test)

### Making prediction on unseen samples
predictions.svm<-predict.train(object=fit.svm, dd.test.frame); # Perform prdiction using the SVM classifier
predictions.knn<-predict.train(object=fit.knn, dd.test.frame); # Perform prdiction using the k-NN classifier

table(predictions.svm, labels.test); # compute a confusion matrix to show the evaluation result

confusionMatrix(predictions.svm,dd.test.frame[,"label"])  # A better way to compute evaluation metrics.

confusionMatrix(predictions.knn,dd.test.frame[,"label"])  # A better way to compute evaluation metrics





