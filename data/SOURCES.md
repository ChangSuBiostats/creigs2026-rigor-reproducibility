# Data sources

Written by `data/get_data.R` (the first entry by its Python predecessor). One entry per download; do not edit by hand.
The newest entry for a file describes the copy currently in `data/raw/`.

## svensson_single_cell_studies.tsv
- Description: Single-cell studies database (Svensson, da Veiga Beltrame & Pachter 2020, Database, doi:10.1093/database/baaa073). Live table; the URL redirects to a published Google Sheet.
- URL: https://nxn.se/single-cell-studies/data.tsv
- Accessed: 2026-11-15 21:27 UTC
- SHA-256: 9bec287212b6f678e0865196cca4c22f51007833c36f6ab0cb06e1a4b3111a4b
- Size: 1120681 bytes, 2202 lines

## cellxgene_collections.json
- Description: CZ CELLxGENE Discover curation API, all public collections with their metadata (CZI Cell Science Program et al. 2025, Nucleic Acids Research, doi:10.1093/nar/gkae1142).
- URL: https://api.cellxgene.cziscience.com/curation/v1/collections
- Accessed: 2026-11-16 14:50 UTC
- SHA-256: 3408e18c34eeff1ade5c91cb7281e5959aef0bbba2eac3d729a646cbe6af6f1f
- Size: 3239094 bytes

## cellxgene_datasets.json
- Description: CZ CELLxGENE Discover curation API, all public datasets with their metadata (CZI Cell Science Program et al. 2025, Nucleic Acids Research, doi:10.1093/nar/gkae1142).
- URL: https://api.cellxgene.cziscience.com/curation/v1/datasets
- Accessed: 2026-11-16 14:50 UTC
- SHA-256: aaf49494f279401341d4078a5030481df6ef1ebfcad82801f597071142d8359c
- Size: 9984000 bytes

## pubmed_counts.tsv
- Description: Number of PubMed records per publication year (2009 to 2025) for the query: ("single cell RNA"[tiab] OR "scRNA-seq"[tiab] OR "single cell transcriptomics"[tiab] OR "single cell transcriptomic"[tiab] OR "single cell transcriptome"[tiab] OR "single nucleus RNA"[tiab] OR "snRNA-seq"[tiab]) NOT review[pt] -- each year adds `AND <year>[dp]`.
- URL: https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi
- Accessed: 2026-11-16 14:51 UTC
- SHA-256: 950c1877ea7343af8ed410840451bd5d45d11df42d60d6739e97b77f3efd0be3
- Size: 4025 bytes
