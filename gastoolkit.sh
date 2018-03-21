#!/bin/bash

### Creating display functions
### Setting colouring
NONE='\033[00m'
OPAQUE='\033[2m'
FLASHING='\033[5m'
BOLD='\033[1m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
STRIKETHROUGH='\033[9m'

RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'

function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}
function echoitalic { 
    echo -e "${ITALIC}${1}${NONE}" 
}
function echonooption { 
    echo -e "${OPAQUE}${RED}${1}${NONE}"
}
function echoerrorflash { 
    echo -e "${RED}${BOLD}${FLASHING}${1}${NONE}" 
}
function echoerror { 
    echo -e "${RED}${1}${NONE}"
}
# errors no option
function echoerrornooption { 
    echo -e "${YELLOW}${1}${NONE}"
}
function echoerrorflashnooption { 
    echo -e "${YELLOW}${BOLD}${FLASHING}${1}${NONE}"
}

script_copyright_message() {
	echo ""
	THISYEAR=$(date +'%Y')
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "+ The MIT License (MIT)                                                                                 +"
	echo "+ Copyright (c) 2015-${THISYEAR} Sander W. van der Laan                                                        +"
	echo "+                                                                                                       +"
	echo "+ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and     +"
	echo "+ associated documentation files (the \"Software\"), to deal in the Software without restriction,         +"
	echo "+ including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, +"
	echo "+ and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, +"
	echo "+ subject to the following conditions:                                                                  +"
	echo "+                                                                                                       +"
	echo "+ The above copyright notice and this permission notice shall be included in all copies or substantial  +"
	echo "+ portions of the Software.                                                                             +"
	echo "+                                                                                                       +"
	echo "+ THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT     +"
	echo "+ NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                +"
	echo "+ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES  +"
	echo "+ OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN   +"
	echo "+ CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                            +"
	echo "+                                                                                                       +"
	echo "+ Reference: http://opensource.org.                                                                     +"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

script_arguments_error() {
	echoerror "$1" # Additional message
	echoerror "- Argument #1 is path_to/filename of the configuration file."
	echoerror "- Argument #2 is path_to/filename of the list of GWAS files with names."
	echoerror ""
	echoerror "An example command would be: run_metagwastoolkit.sh [arg1] [arg2]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                          GASToolKit: A TOOLKIT FOR GENE-BASED ASSOCIATION STUDIES"
echoitalic "                    --- prepare and perform gene-based studies using VEGAS2 or MAGMA---"
echobold ""
echobold "* Version:      v1.0.0"
echobold ""
echobold "* Last update:  2018-03-21"
echobold "* Written by:   Sander W. van der Laan | s.w.vanderlaan@gmail.com."
echobold "* Description:  Prepare and perform gene-based association studies. It will do the following:"
echobold "                - Automatically parse the summary statistics of some (meta-analysis of) GWAS."
echobold "                - Perform VEGAS2 based analyses."
echobold "                - Perform MAGMA based analyses."
echobold ""
echobold "* REQUIRED: "
echobold "  - A high-performance computer cluster with a qsub system"
echobold "  - R v3.2+, Python 2.7+, Perl."
echobold "  - Required Python 2.7+ modules: [pandas], [scipy], [numpy]."
echobold "  - Required Perl modules: [YAML], [Statistics::Distributions], [Getopt::Long]."
echobold "  - Note: it will also work on a Mac OS X system with R and Python installed."
### ADD-IN: function to check requirements...
### This might be a viable option! https://gist.github.com/JamieMason/4761049
echobold ""
echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


##########################################################################################
### SET THE SCENE FOR THE SCRIPT
##########################################################################################

### START of if-else statement for the number of command-line arguments passed ###
if [[ $# -lt 2 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [2] arguments when running *** MetaGWASToolKit ***!"
	script_arguments_error
else
	echo "These are the "$#" arguments that passed:"
	echo "The configuration file.................: "$(basename ${1}) # argument 1
	echo "The list of GWAS files.................: "$(basename ${2}) # argument 2
	
	### SETTING DIRECTORIES (from configuration file).
	# Loading the configuration file (please refer to the MetaGWASToolKit-Manual for specifications of this file). 
	source "$1" # Depends on arg1.
	
	CONFIGURATIONFILE="$1" # Depends on arg1 -- but also on where it resides!!!
	SOFTWARE=${SOFTWARE} # from configuration file
	
	# Where MetaGWASToolKit resides
	METAGWASTOOLKIT=${METAGWASTOOLKITDIR} # from configuration file
	SCRIPTS=${METAGWASTOOLKIT}/SCRIPTS
	RESOURCES=${METAGWASTOOLKIT}/RESOURCES
	
	# Project information
	ORIGINALS=${DATA_UPLOAD_FREEZE} # from configuration file
	PROJECTDIR=${PROJECTDIR} # from configuration file
	SUBPROJECTDIRNAME=${SUBPROJECTDIRNAME} # from configuration file
	OUTPUTDIRNAME=${OUTPUTDIRNAME} # from configuration file
	GWASFILES="$2" # Depends on arg2 -- all the GWAS dataset information
	REFERENCE=${REFERENCE} # from configuration file
	POPULATION=${POPULATION} # from configuration file
	
	# Data preparation settings for parallelization
	CHUNKSIZE=${CHUNKSIZE}
	# Cleaning settings
	MAF=${MAF} # from configuration file
	MAC=${MAC} # from configuration file
	HWE=${HWE} # from configuration file
	INFO=${INFO} # from configuration file
	BETA=${BETA} # from configuration file
	SE=${SE} # from configuration file
	
	# Plotting settings
	RANDOMSAMPLE=${RANDOMSAMPLE}
	
	# Settings for QSUB-system
	# - run times
	QRUNTIME=${QRUNTIME} # from configuration file
	QRUNTIMEPARSER=${QRUNTIMEPARSER} # from configuration file
	QRUNTIMEHARMONIZE=${QRUNTIMEHARMONIZE} # from configuration file
	QRUNTIMEWRAPPER=${QRUNTIMEWRAPPER} # from configuration file
	QRUNTIMECLEANER=${QRUNTIMECLEANER} # from configuration file
	QRUNTIMEPLOTTER=${QRUNTIMEPLOTTER} # from configuration file
	QRUNTIMEMETAPREP=${QRUNTIMEMETAPREP} # from configuration file
	QRUNTIMEANALYZER=${QRUNTIMEANALYZER} # from configuration file
	
	# - run memory
	QMEM=${QMEM} # from configuration file
	QMEMPARSER=${QMEMPARSER} # from configuration file
	QMEMHARMONIZE=${QMEMHARMONIZE} # from configuration file
	QMEMWRAPPER=${QMEMWRAPPER} # from configuration file
	QMEMCLEANER=${QMEMCLEANER} # from configuration file
	QMEMPLOTTER=${QMEMPLOTTER} # from configuration file
	QMEMMETAPREP=${QMEMMETAPREP} # from configuration file
	QMEMANALYZER=${QMEMANALYZER} # from configuration file
	
	#- mailing
	QMAIL=${QMAIL} # from configuration file
	QMAILOPTIONS=${QMAILOPTIONS} # from configuration file
	
	### SETTING THE AVAILABLE REFERENCES -- could also go to the source file
	VINFOFILE=${VINFOFILE} # from configuration file
	
	##########################################################################################
	### CREATE THE OUTPUT DIRECTORIES
	echo ""
	echo "Checking for the existence of the output directory [ ${OUTPUTDIRNAME} ]."
	if [ ! -d ${PROJECTDIR}/${OUTPUTDIRNAME} ]; then
		echo "> Output directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${OUTPUTDIRNAME}
	else
		echo "> Output directory already exists."
	fi
	METAOUTPUT=${OUTPUTDIRNAME}
	
	echo ""
	echo "Checking for the existence of the subproject directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME} ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME} ]; then
		echo "> Subproject directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}
	else
		echo "> Subproject directory already exists."
	fi
	SUBPROJECTDIR=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}

	echo ""	
	echo "Checking for the existence of the raw data directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW ]; then
		echo "> Raw data directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW
	else
		echo "> Raw data directory already exists."
	fi
	# Setting directory for raw data.
	RAWDATA=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW

	echo ""		
	echo "Checking for the existence of the meta-analysis results directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME}/META ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META ]; then
		echo "> Meta-analysis results directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META
	else
		echo "> Meta-analysis results directory already exists."
	fi
	# Setting directory for meta-analysis data.
	METARESULTDIR=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META
	
	echo "Checking for the existence of the meta-analysis temporary results directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP ]; then
		echo "> Meta-analysis results temporary directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP
	else
		echo "> Meta-analysis results temporary directory already exists."
	fi
	# Setting directory for meta-analysis temporary data.
	METATEMPRESULTDIR=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP
	
	##########################################################################################
	### SETTING UP THE OUTPUT AND RAWDATA DIRECTORIES
	echo ""
	### Making raw data directories, unless they already exist. Depends on arg2.
	if [[ ${REFERENCE} = "1Gp1" ]]; then

	  	echo ""
	  	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echo ""
	  	echo "The scene is properly set, and directories are created! 🖖"
	  	echo "MetaGWASToolKit program........................: "${METAGWASTOOLKIT}
	  	echo "MetaGWASToolKit scripts........................: "${SCRIPTS}
	  	echo "MetaGWASToolKit resources......................: "${RESOURCES}
	  	echo "Reference used.................................: "${REFERENCE}
	  	echo "Main directory.................................: "${PROJECTDIR}
	  	echo "Main analysis output directory.................: "${METAOUTPUT}
	  	echo "Subproject's analysis output directory.........: "${METAOUTPUT}/${SUBPROJECTDIRNAME}
	  	echo "Original data directory........................: "${ORIGINALS}
	  	echo "We are processing these cohort(s)..............:"
		while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
			LINE=${GWASCOHORT}
			COHORT=$(echo "${LINE}" | awk '{ print $1 }')
			echo "     * ${COHORT}"
		done < ${GWASFILES}
	  	echo "Raw data directory.............................: "${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW
	  	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echo ""
	
	elif [[ ${REFERENCE} = "HM2" || ${REFERENCE} = "GONL4" || ${REFERENCE} = "GONL5" || ${REFERENCE} = "1Gp3" || ${REFERENCE} = "1Gp3GONL5" ]]; then
		echoerrornooption "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echoerrornooption ""
	  	echoerrorflashnooption "               *** Oh, computer says no! This option is not available yet. ***"
	  	echoerrornooption "Unfortunately using ${REFERENCE} as a reference is not possible yet. Currently only 1Gp1 is available."
	  	echoerrornooption "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		### The wrong arguments are passed, so we'll exit the script now!
		echo ""
		script_copyright_message
		exit 1
	
	else
	  	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echoerror ""
	  	echoerrorflash "                  *** Oh, computer says no! Argument not recognised. ***"
	  	echoerror "You have the following options as reference for the quality control"
	  	echoerror "and meta-analysis:"
	  	echonooption " - [HM2]          HapMap2 (r27, b36, hg18)."
	  	echoerror " - [1Gp1]         1000G (phase 1, release 3, 20101123 version, updated on 20110521 "
	  	echoerror "                  and revised on Feb/Mar 2012, b37, hg19)."
	  	echonooption " - [1Gp3]         1000G (phase 3, release 5, 20130502 version, b37, hg19)."
	  	echonooption " - [GoNL4]        Genome of the Netherlands, version 4."
	  	echonooption " - [GONL5]        Genome of the Netherlands, version 5."
	  	echonooption " - [1Gp3GONL5]    integrated 1000G phase 3, version 5 and GoNL5."
	  	echonooption "(Opaque: not an option yet)"
	  	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		### The wrong arguments are passed, so we'll exit the script now!
		echo ""
		script_copyright_message
		exit 1
	fi
	
#	echobold "#========================================================================================================"
#	echobold "#== FOREST PLOTTER OF META-ANALYSIS RESULTS -- NOT IMPLEMENTED YET"
#	echobold "#========================================================================================================"
#	echobold "#"
#	echonooption "CREATE"
#	echonooption "Perform R-based meta-analysis to plot; likely the results will slightly differ because of Perl <> R"
#	echonooption "Plan:"
#	echonooption "- Extract top hits from clumper"
#	echonooption "- Extract these variants from each input cohort-meta-file ([cohort].reorder.cdat.gz)"
#	echonooption "- Make file out of this (beta, se, p, n, name, variantid, hwe, info)"
#	echonooption "- Input for meta-analysis R script"
#	echonooption "- R: meta-analysis"
#	echonooption "- R: forest plot"
#	echonooption "- R: include heterogeneity"
#
#	echobold "#========================================================================================================"
#	echobold "#== ANNOTATING META-ANALYSIS RESULTS "
#	echobold "#========================================================================================================"
#	echobold "#"
#	echo "Many online tools are available, for your convenience, we will create input files for a/several popular one(s)."
#	echo ""
#	echo "* Creating input file for FUMAGWAS -- http://fuma.ctglab.nl/snp2gene"
#	### We will collect the following information for the summarized data.
#	### Column name -- FUMA column name
#	### VARIANTID 		-- SNP | snpid | markername | rsID: rsID
#	### CHR 			-- CHR | chromosome | chrom: chromosome
#	### POS 			-- BP | pos | position: genomic position (hg19)
#	### CODEDALLELE 	-- A1 | alt | effect_allele | allele1 | alleleB: affected allele
#	### OTHERALLELE 	-- A2 | ref | non_effect_allele | allele2 | alleleA: another allele
#	### P_FIXED 		-- P | pvalue | p-value | p_value | frequentist_add_pvalue | pval: P-value (Mandatory)
#	### BETA_FIXED 		-- Beta | be: Beta
#	### SE_FIXED 		-- SE: Standard error
#	### N_EFF 			-- N: sample size
#	echo "echo \"SNP CHR BP A1 A2 P Beta SE N\" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forFUMA.txt " > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.sh
#	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,CODEDALLELE,OTHERALLELE,P_FIXED,BETA_FIXED,SE_FIXED,N_EFF | tail -n +2 >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forFUMA.txt " >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.sh
#	echo "gzip -vf ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forFUMA.txt " >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.sh
#	qsub -S /bin/bash -N Annot.FUMA -hold_jid METASUM -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.errors -l h_vmem=${QMEMANALYZER} -l h_rt=${QRUNTIMEANALYZER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.sh
#
#	### THINK ABOUT THIS ### 
#	### Should I annotate everything? Or just the clumps? Latter seems logical.
#	echo ""
#	echo "* Creating input file for ANNOVAR -- http://annovar.openbioinformatics.org/en/latest/"
#	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,P_FIXED > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLocusTrack.txt " > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.sh
#	echo "gzip -vf ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLocusTrack.txt " >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.sh
#	qsub -S /bin/bash -N Annot.LocusTrack -hold_jid METASUM -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.errors -l h_vmem=${QMEMANALYZER} -l h_rt=${QRUNTIMEANALYZER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.sh
#	### THINK ABOUT THIS ###

	echobold "#========================================================================================================"
	echobold "#== GENE-BASED ANALYSIS OF META-ANALYSIS RESULTS USING VEGAS2"
	echobold "#========================================================================================================"
	echobold "#"
	# REQUIRED: VEGAS/VEGAS2 settings.
	# Note: we do `cd ${VEGASDIR}` because VEGAS is making temp-files in a special way, 
	#       adding a date-based number in front of the input/output files.
	echo "Creating VEGAS input files..." 
	mkdir -v ${METARESULTDIR}/vegas
	VEGASDIR=${METARESULTDIR}/vegas
	chmod -Rv a+rwx ${VEGASDIR}
	echo "...per chromosome."	
 	for CHR in $(seq 1 23); do
		if [[ $CHR -le 22 ]]; then 
			echo "Processing chromosome ${CHR}..."
			echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,P_FIXED | awk ' \$2==${CHR} ' | awk '{ print \$1, \$3 }' | tail -n +2 > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt " > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
			echo "cd ${VEGASDIR} " >> ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
	  		echo "$VEGAS2 -G -snpandp meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt -custom ${VEGAS2POP}.chr${CHR} -glist ${VEGAS2GENELIST} -upper ${VEGAS2UPPER} -lower ${VEGAS2LOWER} -chr ${CHR} -out meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.fromVEGAS " >> ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
	  		qsub -S /bin/bash -N VEGAS2.${PROJECTNAME}.chr${CHR} -hold_jid METASUM -o ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.log -e ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.errors -l h_vmem=${QMEMVEGAS} -l h_rt=${QRUNTIMEVEGAS} -wd ${VEGASDIR} ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
		
		elif [[ $CHR -eq 23 ]]; then  
			echo "Processing chromosome X..."
			echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,P_FIXED | awk ' \$2==\"X\" ' | awk '{ print \$1, \$3 }' | tail -n +2 > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt " > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
	  		echo "cd ${VEGASDIR} " >> ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
	  		echo "$VEGAS2 -G -snpandp meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt -custom ${VEGAS2POP}.chr${CHR} -glist ${VEGAS2GENELIST} -upper ${VEGAS2UPPER} -lower ${VEGAS2LOWER} -chr ${CHR} -out meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.fromVEGAS " >> ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
	  		qsub -S /bin/bash -N VEGAS2.${PROJECTNAME}.chr${CHR} -hold_jid METASUM -o ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.log -e ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.errors -l h_vmem=${QMEMVEGAS} -l h_rt=${QRUNTIMEVEGAS} -wd ${VEGASDIR} ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
		
		else
			echo "*** ERROR *** Something is rotten in the City of Gotham; most likely a typo. Double back, please."	
			exit 1
		fi

	done

	echobold "#========================================================================================================"
	echobold "#== GENE-BASED ANALYSIS OF META-ANALYSIS RESULTS USING MAGMA"
	echobold "#========================================================================================================"
	echobold "#"
	### REQUIRED: MAGMA settings.
	### Head for MAGMA input
	### SNP CHR BP P NOBS 
	echo "Creating MAGMA input files..." 
	mkdir -v ${METARESULTDIR}/magma
	MAGMARESULTDIR=${METARESULTDIR}/magma
	chmod -Rv a+rwx ${MAGMARESULTDIR}
	echo " - whole-genome..."
 	echo "echo \"SNP CHR BP P NOBS\" > ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMAGMA.txt " > ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.sh
 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,P_FIXED,N_EFF | tail -n +2 | awk '{ print \$1, \$2, \$3, \$4, int(\$5) }' >> ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMAGMA.txt " >> ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.sh
	echo "${MAGMA} --annotate --snp-loc ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMAGMA.txt --gene-loc ${MAGMAGENES} --out ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.fromMAGMA.annotated " >> ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.sh
	qsub -S /bin/bash -N MAGMA.ANALYSIS.${PROJECTNAME} -hold_jid METASUM -o ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.log -e ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.errors -l h_vmem=${QMEMMAGMA} -l h_rt=${QRUNTIMEMAGMA} -wd ${MAGMARESULTDIR} ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.sh

	echo "${MAGMA} --bfile ${MAGMAPOP} synonyms=${MAGMADBSNP} synonym-dup=drop-dup --pval ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMAGMA.txt ncol=NOBS --gene-annot ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.fromMAGMA.annotated.genes.annot --out ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.fromMAGMA.genesannotated " > ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.annotMAGMA.sh
 	qsub -S /bin/bash -N MAGMA.ANNOTATION.${PROJECTNAME} -hold_jid MAGMA.ANALYSIS.${PROJECTNAME} -o ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.annotMAGMA.log -e ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.annotMAGMA.errors -l h_vmem=${QMEMMAGMA} -l h_rt=${QRUNTIMEMAGMA} -wd ${MAGMARESULTDIR} ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.annotMAGMA.sh

 	echo "${MAGMA} --gene-results ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.fromMAGMA.genesannotated.genes.raw --set-annot ${MAGMAGENESETS} --out ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.fromMAGMA.gsea " > ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.gseaMAGMA.sh
 	qsub -S /bin/bash -N MAGMA.GSEA.${PROJECTNAME} -hold_jid MAGMA.ANNOTATION.${PROJECTNAME} -o ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.gseaMAGMA.log -e ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.gseaMAGMA.errors -l h_vmem=${QMEMMAGMA} -l h_rt=${QRUNTIMEMAGMA} -wd ${MAGMARESULTDIR} ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.gseaMAGMA.sh
 
#	echobold "#========================================================================================================"
#	echobold "#== LD SCORE REGRESSION -- currently only the *input* files for LD-Hub are created --"
#	echobold "#========================================================================================================"
#	echobold "#"
#	echo "We will make use of LD-Hub (http://ldsc.broadinstitute.org) to calculate genetic correlation with other traits."
#	echo ""
#	echo "Generating LD-Hub input file."
#	mkdir -v ${METARESULTDIR}/ldscore
#	LDSCOREDIR=${METARESULTDIR}/ldscore
#	echo "echo \"snpid A1 A2 Zscore N P-value\" > ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.temp " > ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
#	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CODEDALLELE,OTHERALLELE,Z_FIXED,N_EFF,P_FIXED | tail -n +2 >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.temp " >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
#	echo "${SCRIPTS}/mergeTables.pl --file1 ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.temp --file2 ${RESOURCES}/w_hm3.noMHC.snplist.txt.gz --index snpid --format GZIP2 | awk '{ print \$1, \$4, \$5, \$6, \$7, \$8 }' > ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.txt " >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
#	### LD-Hub expects a ZIPPED file!!!
#	echo "cd ${LDSCOREDIR}" >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
#	echo "zip -v meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.txt.zip meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.txt" >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
# 	echo "rm -v ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.temp" >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
#	qsub -S /bin/bash -N LDSCORE.${PROJECTNAME} -hold_jid METASUM -o ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.log -e ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.errors -l h_vmem=${QMEMLDSCORE} -l h_rt=${QRUNTIMELDSCORE} -wd ${LDSCOREDIR} ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
#
#	echobold "#========================================================================================================"
#	echobold "#== MR BASE -- currently only the *input* files for MR-Base are created --"
#	echobold "#========================================================================================================"
#	echobold "#"
#	### add in p-value selection in configuration
#	### add in units of exposure
#	echo "We will make use of MR-Base (http://www.mrbase.org/) to infer causality to other traits."
#	echo ""
#	echo "Generating MR-Base input file, based on p-value <= ${MRBASEPVAL}."
#	mkdir -v ${METARESULTDIR}/mrbase
#	MRBASEDIR=${METARESULTDIR}/mrbase
#	echo "echo \"SNP beta se pval effect_allele other_allele eaf samplesize Phenotype\" > ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.txt " > ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.sh
#	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,BETA_FIXED,SE_FIXED,P_FIXED,CODEDALLELE,OTHERALLELE,CAF,N_EFF > ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.temp " >> ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.sh
#	echo "cat ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.temp | tail -n +2 | awk '\$4 <= ${MRBASEPVAL}' | awk '{ print \$0, \"${PROJECTNAME}\" }' >> ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.txt " >> ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.sh
#	echo "rm -v ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.temp " >> ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.sh
# 	qsub -S /bin/bash -N MRBASE.${PROJECTNAME} -hold_jid METASUM -o ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.log -e ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.errors -l h_vmem=${QMEMMRBASE} -l h_rt=${QRUNTIMEMRBASE} -wd ${MRBASEDIR} ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.sh
#
#	echobold "#========================================================================================================"
#	echobold "#== DEPICT -- needs implementation --"
#	echobold "#========================================================================================================"
#	echobold "#"
#	echonooption "- download DEPICT"
#	echonooption "- do clumping for additional DEPICT analysis; their advise is p<5e-5."
#	echonooption "- add in DEPICT options in configuration file"

	### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message