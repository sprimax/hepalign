
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
	// storeDir params.cache
	input:
		path fastafiles
	output:
		path "allSeqs.fasta"
	"""
		touch allSeqs.fasta
		cat ${fastafiles} > allSeqs.fasta
	"""
}

process mafft {
	// storeDir params.cache
	container "https://depot.galaxyproject.org/singularity/mafft%3A7.525--h031d066_1"
	input:
		path fastafile
	output:
		path "mafftOut*"
	"""
		mafft ${fastafile} > mafftOut.fasta
		mafft --auto ${fastafile} > mafftOutAuto.fasta
	"""
}

process trimal {
	publishDir params.out, mode: 'copy', overwrite: true
	container "https://depot.galaxyproject.org/singularity/trimal%3A1.5.0--h9948957_2"
	input:
		path fastafile
	output:
		path "${fastafile.getSimpleName()}*"
	"""
		trimal -in ${fastafile} -out ${fastafile.getSimpleName()}_trimal.fasta -htmlout ${fastafile.getSimpleName()}_trimal.html -automated1
	"""
}

// trimal -in ${fastafile} -out ${fastafile.getSimpleName()}.fasta -htmlout ${fastafile.getSimpleName()}.html -automated1


workflow {
    print "Given accession number is: ${params.accession}"
	download | onefile | mafft | trimal

}