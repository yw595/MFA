require(RCurl)
require(XML)

cpds = read.table("testKEGG.txt", header=TRUE, row.names=1,sep="\t")
firstPartPage = 'http://www.genome.jp/dbget-bin/www_bget?cpd:'

for (j in 1: dim(cpds)[1] )
{
	thepage = readLines(paste(firstPartPage,cpds[j,1],sep=""))
	#print(cpds[j,1])
	mypattern = "\\?map"
	datalines = grep(mypattern,thepage,value=TRUE)
	if(length(datalines)>0)
	{
		maplist = strsplit(datalines, ">map", fixed = FALSE, perl = FALSE, useBytes = FALSE)
		divlist = strsplit(datalines, "<div>", fixed = FALSE, perl = FALSE, useBytes = FALSE)
		maplist = maplist[[1]][2:length(maplist[[1]])]
		divlist = divlist[[1]][2:length(divlist[[1]])]
		for (k in 1:length(maplist))
		{
			print(paste("map",substring(maplist[k],0,5),sep=""))
		}
		for (k in 1:length(divlist))
		{
			print(divlist[k])
			print(strsplit(divlist[k], "</div>", fixed = FALSE, perl = FALSE, useBytes = FALSE)[[1]][2])
		}
	}
}
