require(RCurl)
require(XML)

cpds = read.table("testKEGG.txt", header=TRUE, row.names=1,sep="\t")
firstPartPage = 'http://www.genome.jp/dbget-bin/www_bget?cpd:'

for (j in 1: dim(cpds)[1] )
{
	thepage = readLines(paste(firstPartPage,cpds[j,1],sep=""))
	#my pattern occurs in a tag near left end of line
	mypattern = "\\?map"
	datalines = grep(mypattern,thepage,value=TRUE)
	if(length(datalines)>0)
	{
		#>map occurs in front of all KEGG pathway ids
		maplist = strsplit(datalines, ">map", fixed = FALSE, perl = FALSE, useBytes = FALSE)
		#<div> occurs in front of the pathway name
		#use left to distinguish from 5.5em"><div><nobr> which also occurs regularly
		divlist = strsplit(datalines, "left\"><div>", fixed = FALSE, perl = FALSE, useBytes = FALSE)
		maplist = maplist[[1]][2:length(maplist[[1]])]
		divlist = divlist[[1]][2:length(divlist[[1]])]
		for (k in 1:length(maplist))
		{
			print(paste("map",substring(maplist[k],0,5),sep=""))
		}
		for (k in 1:length(divlist))
		{
			print(divlist[k])
			#split out the part the divlist entry before </div>, which terminates the pathway name
			print(strsplit(divlist[k], "</div>", fixed = FALSE, perl = FALSE, useBytes = FALSE)[[1]][1])
		}
	}
}
