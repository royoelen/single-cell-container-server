FROM ubuntu:26.04

LABEL Maintainer="Roy Oelen (roy.oelen@gmail.com)"
LABEL RStudio_Version="2026.06.0-242"
LABEL R_Version="4.6.1"
LABEL Image_Version="v2.1"
LABEL Repository="https://github.com/royoelen/single-cell-container-server"

# Environment variables
ENV RSTUDIO_VERSION=2026.06.0-242 \
    R_VERSION=4.6.1 \
    DEBIAN_FRONTEND=noninteractive \
    PATH=/usr/lib/rstudio-server/bin:${PATH} \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

# Copy setup scripts (Singularity %setup)
COPY rstudio_auth.sh /usr/lib/rstudio-server/bin/rstudio_auth
COPY ldap_auth.py /usr/lib/rstudio-server/bin/ldap_auth

# Main installation block (Singularity %post)
RUN apt-get update && \
    apt-get install -y tzdata locales && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.utf8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      software-properties-common dirmngr wget \
      libcurl4-openssl-dev libssl-dev libxml2-dev libcairo2-dev \
      libxt-dev libopenblas-dev libgeos-dev libharfbuzz-dev \
      libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev \
      libjpeg-dev cmake make g++ libhdf5-serial-dev libboost-all-dev \
      git libgit2-dev default-jdk libmpfr-dev curl libgmp3-dev \
      libmagick++-dev libtool libglpk-dev pandoc libudunits2-dev \
      libgdal-dev libgsl-dev && \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | \
      tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository \
      "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      r-base=${R_VERSION}* r-base-core=${R_VERSION}* r-base-dev=${R_VERSION}* \
      r-recommended=${R_VERSION}* r-base-html=${R_VERSION}* r-doc-html=${R_VERSION}* && \
    echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" \
      >> /usr/lib/R/etc/Rprofile.site && \
    mkdir -p /library && \
    echo "R_LIBS_SITE=/library:\${R_LIBS_SITE}" >> /usr/lib/R/etc/Renviron.site && \
    apt-get install -y ca-certificates gdebi-core && \
    wget --no-verbose -O rstudio-server.deb \
      "https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" && \
    gdebi -n rstudio-server.deb && rm -f rstudio-server.deb && \
    echo "directory=~/rstudio-server" >> /etc/rstudio/database.conf && \
    wget https://repo.anaconda.com/archive/Anaconda3-2025.12-2-Linux-x86_64.sh && \
    bash Anaconda3-2025.12-2-Linux-x86_64.sh -b -p /opt/anaconda3 && \
    ln -s /opt/anaconda3/bin/conda /usr/local/bin/conda && \
    ln -s /opt/anaconda3/bin/pip /usr/local/bin/pip && \
    ln -s /opt/anaconda3/bin/python /usr/local/bin/python && \
    rm Anaconda3-2025.12-2-Linux-x86_64.sh && \
    /opt/anaconda3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    /opt/anaconda3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    /opt/anaconda3/bin/conda update -y -n base -c anaconda conda && \
    /opt/anaconda3/bin/conda install -y -c anaconda python==3.11 && \
    /opt/anaconda3/bin/conda config --add channels defaults && \
    /opt/anaconda3/bin/conda config --add channels bioconda && \
    /opt/anaconda3/bin/conda config --add channels conda-forge && \
    /opt/anaconda3/bin/conda install -y numpy pandas scikit-learn seaborn && \
    /opt/anaconda3/bin/conda install -y -c bioconda scanpy && \
    /opt/anaconda3/bin/conda install -y -c conda-forge jupyterlab && \
    pip install macs3 && \
    pip install ldap3==2.9 && \
    ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin && \
    rm -rf /var/lib/apt/lists/*

# Install R packages (CRAN + Bioconductor)
RUN R --slave -e 'install.packages(c("igraph","R.utils","optparse","reshape2","plyr","dplyr","ggridges","Seurat","MatrixEQTL","mlrMBO","circlize","vcfR","hexbin","cowplot","tidyverse","ggnewscale","enrichR","ggpubr","rmarkdown","ggvenn","fido","UpSetR","sctransform","compositions","lmerTest","nlme","lme4","MASS","networkD3","xlsx","openxlsx","scatteR","statmod","textTinyR","pandoc","irlba","OlinkAnalyze","fastR","meta","bestNormalize","svMisc"))' && \
    R --slave -e 'BiocManager::install(c("MAST","variancePartition","edgeR","BiocParallel","DESeq2","VariantAnnotation","SingleR","OmnipathR","ComplexHeatmap","pcaMethods","clusterProfiler","organism","enrichplot","pathview","phyloseq","MOFA2","muscat","UCell","batchelor","TOAST","CellBench","BiocStyle","scater","BuenColors","Rmpfr","glmGamPoi","snpStats","rhdf5","Rfast","chromVAR","motifmatchr","TFBSTools","GenomeInfoDb","GenomicRanges","IRanges","Rsamtools","S4Vectors","BiocGenerics"))' && \
    R --slave -e 'install.packages("Signac")'

# Default command (Singularity %runscript)
CMD ["rserver"]
