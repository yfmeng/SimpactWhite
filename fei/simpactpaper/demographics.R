folder<-'/Users/feimeng/Dropbox/Simpact/output/'
fileindex<-1
shapes <-c(3.9,4,4.3)
scales<-c(65,72,80)
t<-2
for (i in 1:3){
  shape <- shapes[i]
  scale <- scales[i]
  bins <- seq(10,100,10)
  freqs <- bins
  filename <- sprintf('%spop_%04d_pop_%g_%g.csv',folder,fileindex,scale,shape)
  data <- read.csv(filename)
  valid <- data$born[is.nan(data$deceased)]
  valid <- t-valid
  freqs[1]<-sum(valid<=bins[1])
  for (j in 2:length(bins)){
    freqs[j]<-sum(valid>bins[j-1]&valid<=bins[j])
  }
  freqs<-freqs/sum(freqs)
  output<-data.frame(Age = bins,Frequency = freqs)
  filename <- sprintf('%sage_structure_%g_%g.csv',folder,fileindex,scale,shape)
  write.csv(output,file = filename)
}

