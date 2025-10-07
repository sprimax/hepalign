
// standard set by params.accession = "M21012"
// can be overtuned by $ nextflow run xam.nf --accession 123456
// Change in --accession will be shown in the first workflowstep "print"
params.accession = "M21012"
params.download = "${projectDir}/downloads"
params.cache = "${projectDir}/cache"
params.out = "${projectDir}/output"

process download {
	storeDir params.download
	output:
		path "*.fasta"
	"""
        wget \
        "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${params.accession}&rettype=fasta&retmode=text" \
        -O ${params.accession}.fasta
		wget \
        "https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/hepatitis_combined.fasta?inline=false" \
        -O hepatitis_combined.fasta
	"""
}

process onefile {
	storeDir params.cache
	input:
		path fastafiles
	output:
		path "allSeqs.fasta"
	"""
		touch allSeqs.fasta
		cat ${fastafiles} > allSeqs.fasta
	"""
}


workflow {
    print "Given accession number is: ${params.accession}"
	download | onefile

}