#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

def helpMessage () {
    log.info """
    ONTProcessing workflow
    Roberto Barrero, 17/10/2022
    Craig Windell, 17/10/2022

    Usage:
    Run the command
    nextflow run eresearchqut/deepvariant {optional arguments}...

    Optional arguments:
      -resume                           Resume a failed run
      --outdir                          Path to save the output file
                              Default: 'results'
      --samplesheet '[path/to/file]'    Path to the csv file that contains the list of
                                        samples to be analysed by this pipeline.
                              Default:  'index.csv'
      Contents of samplesheet csv:
        sampleid,sample_files,sample_files_index,reference
        SAMPLE01,/path/to/aligned/SAMPLE01.bam,/path/to/aligned/SAMPLE01.bam.bai,/path/to/reference.fasta

        sample_files can refer to a folder with a number of
        files that will be merged in the pipeline

        --dv_region                     Region in [contig_name:start-end] format.
                              Default:  NC_001477_ref:1-10735

        --dv_nanopore_version           Set to call variants on R9.4.1 Guppy or \
                                        R10.4 Q20 Oxford Nanopore reads
                                        ont_r9_guppy5_sup, ont_r10_q20, null
                              Default:  ont_r9_guppy5_sup

    """.stripIndent()
}
// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

process DEEPVARIANT {
  publishDir "${params.outdir}", mode: 'link', saveAs: { file(it).getName() }
  tag "${sampleid}"
  label 'large'

  container 'kishwars/pepper_deepvariant:r0.8'

  input:
    tuple val(sampleid), path(sample_sorted), path(sample_sorted_index), path(reference)
  output:
    path "outdir/${sampleid}.*"
  script:
  switch (params.dv_nanopore_version) {
    case "ont_r9_guppy5_sup":
    case "ont_r10_q20":
      nanopore_version = "--${params.dv_nanopore_version}"
      break;
    default:
      nanopore_version =''
     break;
  }
  """
  run_pepper_margin_deepvariant call_variant \
  -b "${sample_sorted}" \
  -f "${reference}" \
  -o "outdir" \
  -p "${sampleid}" \
  -t ${task.cpus} \
  -r ${params.dv_region} \
  ${nanopore_version}
  """
}

workflow {
  if (params.samplesheet) {
    Channel
      .fromPath(params.samplesheet, checkIfExists: true)
      .splitCsv(header:true)
      .map{ row-> tuple((row.sampleid), file(row.sample_files),file(row.sample_files_index), file(row.reference)) }
      .set{ ch_sample }
  } else { exit 1, "Input samplesheet file not specified!" }

  DEEPVARIANT ( ch_sample )
}

