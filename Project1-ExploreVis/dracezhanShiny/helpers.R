VGdata[c(6:14)] <- lapply(VGdata[c(6:14)], as.numeric)
VGdataCor = cor(VGdata[,6:14], use="pairwise.complete.obs")
VGCorPlot = corrplot(VGdataCor, method = 'circle')