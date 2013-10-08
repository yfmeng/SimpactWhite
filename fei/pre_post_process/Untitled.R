setwd('/Users/feimeng/Dropbox/SIMPACT_HMC/output')
prev <-c()
num <-c(600, 700)
index <-101;
for (n in num){
	for (i in 35:38){
		file <- sprintf('allC_%04d.csv',index)
		population<-read.csv(file)
		previ <- prevalence(population,30)
		previ <-previ$adult.prev
		name <- paste(n,i,sep = '-')
		previ <- cbind(name,t(previ))
		prev <- rbind(prev,previ)
		index <-index+1
		}
	}
write.csv(prev,file = 'prevalence2.csv')
