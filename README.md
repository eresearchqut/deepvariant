# Deepvariant workflow

Roberto Barrero, 19/10/2022

Craig Windell, 19/10/2022

## Usage:
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

        --dv_nanopore_version           Set to call variants on R9.4.1 Guppy or
                                        R10.4 Q20 Oxford Nanopore reads
                                        ont_r9_guppy5_sup, ont_r10_q20, null
                              Default:  ont_r9_guppy5_sup