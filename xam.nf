
params.accession = "M21012"
params.download = "${projectDir}/downloads"
params.with_cache = false
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
	if (params.with_cache){storeDir params.cache}
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
	if (params.with_cache){storeDir params.cache}
	container "https://depot.galaxyproject.org/singularity/mafft%3A7.525--h031d066_1"
	input:
		path fastafile
	output:
		path "mafftOut.fasta*"
	"""
		mafft ${fastafile} > mafftOut.fasta
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

workflow {
    print "Given accession number is: ${params.accession}"
	print "Accession number parameter: --accession ######"
	print "Create cache directory for intermediate files --with_cache"

	download | onefile | mafft | trimal

}