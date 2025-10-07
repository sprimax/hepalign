
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
		path "${params.accession}.fasta"
	"""
        wget \
        "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${params.accession}&rettype=fasta&retmode=text" \
        -O ${params.accession}.fasta
	"""
}


workflow {
    print "Given accession number is: ${params.accession}"
	download()

}