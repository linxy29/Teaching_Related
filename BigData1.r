
##################################################
# Part 1: Introduction to matrix manipulation in R
##################################################

### A variable can hold a single value
x <- 1; # This variable has name 'x'. It is assigned to hold the number 1
print(x);

### A vector holds an ordered list of values
x <- 1:10; #In this case, x is a vector of cosecurtive natural numbers 1, 2, 3,..., 10
print(x);

### We can perform simple arithmetic operations on a vector
y <- x^2 - 2*x + 4;  # Simple algebraic operations can be applied to all the values in a vector. In this case, y is also a vector of 10 values.
print(y);
plot(x, y, type="b", main="Relationship between x and y");   # The 'plot' function generates a 2-dimensional x-y plot 

### A matrix holds an ordered arrangement of n x m numbers (n is number of rows, and m is number of columns)
x <- matrix(1:15, nrow=5, ncol=3)  #x is assigned to be a matrix consisting of 2 rows and 5 columns, containing the values 1, 2, 3,..., 15
print(x);

### A matrix can be manipulated 
x.times.2 <- x*2; # this operation multiplies all values in x by 2
print(x.times.2);
x.plus.1 <- x+1; # this operation adds all values in x by 1
print(x.plus.1);
x.transposed <- t(x);   # this operation transposes a n x m matrix to a m x n matrix
print(x.transposed);   

### You can access different elements of a matrix
print(x);  # Show the entire matrix
print(x[2,2]);  # Show the element in the second row and second column
print(x[1:2,2:3]); # Show the elements in row 1 and 2, and columns 2 and 3. The output is a matrix
print(x[1,]);  # Show the elements in the 1st ro. The output is a vector
print(x[,3]); # Show the elements in the 3rd column. The output is a vector
print(x[-1,]); # This operation show the elements in all rows and columns, EXCEPT the 1st row

### You can add row and column names to a matrix, and access elements by these names
rownames(x) <- paste("Row",1:5,sep="");
colnames(x) <- paste("Col", LETTERS[1:3], sep="");
print(x);
print(x["Row3",]);   
print(x[,"ColB"]);
print(x["Row3", "ColB"]);

### Generate summary statistics of a matrix 
apply(x, 1, sum); #this operation compute the sum of all values of each row (e.g., dimension 1)
apply(x, 2, mean); #this operation computer the arithmetic means of each column (e.g., dimension 2)

### You can use ? in front of any function to display it's usage
?rownames




######################################################################
# Part 2: Using R to analyse a simple gene expression matrix
######################################################################

### Simulate a gene expression data set consisting of 10 samples (5 from disease cases and 5 from healthy controls) and 50 genes (5 up-regulated in disease, 5 down-regulated in disease, 40 not differentially regulated)
set.seed(1); #This operation set the seed to the random number generation to be 1. This ensures the results are reproducible across everyone's execution
dd.up <- cbind( matrix( rnorm(25, 9, 0.3), 5, 5), matrix( rnorm(25, 7, 0.3), 5, 5) )  # This generates the expression of five genes that are up-regulated in the disease group compared to the control group
dd.down <- cbind( matrix( rnorm(25, 7, 0.3), 5, 5), matrix( rnorm(25, 9, 0.3), 5, 5) ) # This generates the expression of five genes that are down-regulated in the disease group compared to the control group
dd.others <- matrix( rnorm(400, 8, 0.3), 40, 10); # This generates the expression of 40 genes that do not hvae differential expression across the 10 samples regardless of sample grouping
dd<-rbind(dd.up, dd.down, dd.others);  # This is the combined data matrix consisting of 50 genes and 10 samples

dim(dd); ### This show the dimension of the matrix (50 rows and 10 columns)
rownames(dd) <- paste("Gene", 1:50, sep=""); # This operation add a name to each row (Gene1, Gene2, ..., Gene50)
colnames(dd) <- paste("Sample", 1:10, sep=""); # This operation add a name to each column (Sample1, Sample2, Sample3,...Sample10)

head(dd); # This operation display the top few rows and columns of a matrix

### Saving the data in a matrix as a tab-delimited text file
write.table(dd, file="Simulated.data.txt", sep="\t", quote=F); # This operation save the data in a tab-delimited text file called 'Simulated.data.txt'



### Reading the data from a tab-delimited text file
dd<-as.matrix(read.table(file="Simulated.data.txt", sep="\t", stringsAsFactors=F, header=T)); # This operation read the data in a tab-delimited text file called 'Simulated.data.txt'

# In the example above, if the file is saved using sep="," the file is called a comma-separated values file (CSV) file. Such a file can be read using sep="," as well

### Visualisation of distribution of values of each sample
boxplot(dd, outline=F, main="Distribution of values", ylab="Gene expression values", las=2, frame=F);

### Visualisation of the expression matrix. Rows and columns are re-ordered based on hierarchical clustering
heatmap(dd, scale="none", main="All");

### Calculate correlations between every pairs of samples, then visualisate the resulting correlation matrix as a heat map, in which the rows and columns are re-ordered based on hierarchical clustering
cc <- cor(dd, method="pearson")   # This operation calculate pairwise (Pearson) correlation between every pairs of columns in the matrix
print(cc);
heatmap(cc, scale="none", main="Pairwise correlation");


### Principal component analysis - for dimensionality reduction
pca <- prcomp(t(dd),scale=T);
summary(pca)

colours <- rep("grey", 10);  # create a vector 'colours' by repeating the word 'grey' 10 times
colours[1:5] <-"red";
colours[6:10] <- "blue";
plot(pca$x[,1], pca$x[,2], col=colours, pch=16, main="Principal Component Analysis", xlab="PC1", ylab="PC2", xlim=c(-6,6), ylim=c(-6,6), cex=1.5, bty="n");
text(pca$x[,1], pca$x[,2]-0.3, labels=colnames(dd), cex=0.8)





