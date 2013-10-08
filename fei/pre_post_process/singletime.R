rm(list=ls())

setwd('/Users/feimeng/Dropbox/Survey data')
complete<-read.csv('complete.csv')
st<-as.Date(complete$start_date)
et<-as.Date(complete$end_date)
total.time<-max(et)-min(st)
active.time<-c()
attach(complete)
for (i in id){
	index <- episode_id[id == i]
   ord<-order(et[index])
	dates <- cbind(st[index][ord],et[index][ord])
	if (nrow(dates)==1){
		active.time[i]<- dates[1,2]-dates[1,1]
		} 
		else {

			for (j in 1:(nrow(dates)-1)){
				k <- nrow(dates)-j+1
				if (dates[k,1]<=dates[k-1,2]){
					dates[k-1,1]<-min(dates[k-1,1],dates[k,1])
					dates[k-1,2]<-dates[k,2]
					dates<-dates[-k,]
					}
				}
				if (nrow(dates)>1){active.time[i]<-sum(dates[,2]-dates[,1])}
				else{active.time[i]<-sum(dates[2]-dates[1])}
			}
	}