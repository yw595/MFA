#####Extract Kegg pathways
require(RCurl)
require(XML)

output=matrix(0,4705,3)
Identifiers=read.table("database_CarbonFateMaps2.txt", header=TRUE, row.names=1,sep="\t")
output=as.data.frame(output)
#colnames(output)<- Identifiers[,1]

firstPartPage='http://www.genome.jp/dbget-bin/www_bget?rn:'

for (j in 1: dim(Identifiers)[1] )
{
	thepage = readLines(paste(Identifiers[j,1],sep=""))
	print(j)
	print(paste(Identifiers[j,1],sep=""))

	mypattern = "cpd:"
	datalines = grep(mypattern,thepage,value=TRUE)
	if(length(datalines)>0)
	{
		cpdlist = strsplit(datalines, "=>", fixed = FALSE, perl = FALSE, useBytes = FALSE)
		reactantlist = strsplit(cpdlist[[1]][1], "cpd:", fixed = FALSE, perl = FALSE, useBytes = FALSE)
		productlist = strsplit(cpdlist[[1]][2], "cpd:", fixed = FALSE, perl = FALSE, useBytes = FALSE)
		reactantlist = reactantlist[[1]][2:length(reactantlist[[1]])]
		productlist = productlist[[1]][2:length(productlist[[1]])]
		output[j,1] = as.character(Identifiers[j,1])
		output[j,1] = substring(output[j,1],nchar(output[j,1])-5)
		print(output[j,1])
		reactantString = ""
		productString = ""
		for (k in 1:length(reactantlist))
		{
			reactantString = paste(reactantString, substring(reactantlist[k],1,6), sep = " ")
		}
		output[j,2] = substring(reactantString,2)
		print(output[j,2])
		for (k in 1:length(productlist))
		{
			productString = paste(productString, substring(productlist[k],1,6), sep = " ")
		}
		output[j,3] = substring(productString,2)
		print(output[j,3])
	}
	else
	{
		output[j,1]=0
		output[j,2]=0
		output[j,3]=0
	}
}

write.table(output,file = "KEGGparse.csv",row.names=FALSE,col.names=FALSE,sep=",")
