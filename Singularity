BootStrap: docker
From: ubuntu:24.04

%labels
  Maintainer Jeremy Nicklas, Roy Oelen
  RStudio_Version 2024.04.2-764

%help
  This will run RStudio Server

%apprun rserver
  exec rserver "${@}"

%runscript
  exec rserver "${@}"

%environment
  export PATH=/usr/lib/rstudio-server/bin:${PATH}

%setup
  install -Dv \
    rstudio_auth.sh \
    ${SINGULARITY_ROOTFS}/usr/lib/rstudio-server/bin/rstudio_auth
  install -Dv \
    ldap_auth.py \
    ${SINGULARITY_ROOTFS}/usr/lib/rstudio-server/bin/ldap_auth

%post
  # Software versions
  export RSTUDIO_VERSION=2024.12.0-467
  export R_VERSION=4.4.2

  # build necessities
  export PAT='your_path'
  export EMAIL='your.name@mail.com'
  export USERNAME='yourname'

  # Get dependencies
  apt-get update
  apt-get install -y --no-install-recommends \
    locales

  # Configure default locale
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen en_US.utf8
  /usr/sbin/update-locale LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8

  # Install R
  apt-get update
  apt-get install -y --no-install-recommends \
    software-properties-common \
    dirmngr \
    wget
  wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | \
    tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
  add-apt-repository \
    "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
  apt-get install -y --no-install-recommends \
    r-base=${R_VERSION}* \
    r-base-core=${R_VERSION}* \
    r-base-dev=${R_VERSION}* \
    r-recommended=${R_VERSION}* \
    r-base-html=${R_VERSION}* \
    r-doc-html=${R_VERSION}* \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libcairo2-dev \
    libxt-dev \
    libopenblas-dev \
    libgeos-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    cmake \
    make \
    g++ \
    libhdf5-serial-dev \
    libboost-all-dev \
    git \
    libgit2-dev \
    default-jdk \
    libmpfr-dev \
    curl \
    libgmp3-dev \
    libmagick++-dev \
    libtool \
    libglpk-dev \
    pandoc
  apt-get install -y libudunits2-dev
  apt-get install -y libgdal-dev
  apt-get install -y libgsl-dev

  # install cuda toolkit
  # https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_local
  export DEBIAN_FRONTEND=noninteractive
  # install latest CUDA
  wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
  mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
  wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb
  dpkg -i cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb
  cp /var/cuda-repo-ubuntu2404-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
  apt-get update
  apt-get -y install cuda-toolkit-12-8

  # Add a default CRAN mirror
  echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/lib/R/etc/Rprofile.site

  # Add a directory for host R libraries
  mkdir -p /library
  echo "R_LIBS_SITE=/library:\${R_LIBS_SITE}" >> /usr/lib/R/etc/Renviron.site

  # Install RStudio Server
  apt-get update
  apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    gdebi-core
  wget \
    --no-verbose \
    -O rstudio-server.deb \
    "https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb"
  gdebi -n rstudio-server.deb
  rm -f rstudio-server.deb

  # set the server directory to be in /home, because the container is not writeable
  echo "directory=~/rstudio-server" >> /etc/rstudio/database.conf

  # install conda
  export CONDA_VERSION=Anaconda3-2024.10-1-Linux-x86_64
  wget https://repo.anaconda.com/archive/${CONDA_VERSION}.sh
  bash ${CONDA_VERSION}.sh -b -p /opt/anaconda3
  chmod +x /opt/anaconda3
  ln -s /opt/anaconda3/bind/conda /usr/local/bin/conda
  ln -s /opt/anaconda3/bin/pip /usr/local/bin/pip
  ln -s /opt/anaconda3/bin/python /usr/local/bin/python
  rm ${CONDA_VERSION}.sh
  # update conda to the latest version
  /opt/anaconda3/bin/conda update -n base -c anaconda conda
  # install python
  /opt/anaconda3/bin/conda install -c anaconda python==3.11
  # install python tools
  /opt/anaconda3/bin/conda config --add channels defaults
  /opt/anaconda3/bin/conda config --add channels bioconda
  /opt/anaconda3/bin/conda config --add channels conda-forge
  # install libraries
  /opt/anaconda3/bin/conda install -c anaconda numpy
  /opt/anaconda3/bin/conda install -c anaconda pandas
  /opt/anaconda3/bin/conda install -c anaconda scikit-learn
  /opt/anaconda3/bin/conda install -c anaconda seaborn
  /opt/anaconda3/bin/conda install -c bioconda scanpy
  /opt/anaconda3/bin/conda install -c conda-forge jupyterlab
  #/opt/anaconda3/bin/conda install -c conda-forge tensorflow
  /opt/anaconda3/bin/conda install pip
  #/opt/anaconda3/bin/pip install scCODA
  # install macs2
  wget https://github.com/macs3-project/MACS/archive/refs/tags/v2.2.9.1.tar.gz
  tar -xvzf v2.2.9.1.tar.gz
  cd MACS-2.2.9.1/
  # patch
  #sed -i 's/tstate->use_tracing/tstate->tracing/g' MACS2/Prob.c
  /opt/anaconda3/bin/pip install .
  cd
  # install macs3
  /opt/anaconda3/bin/pip install macs3
  # install scenic plus
  git clone https://github.com/aertslab/scenicplus
  cd scenicplus
  git checkout development
  /opt/anaconda3/bin/pip install .
  cd

  # Add support for LDAP authentication
  /opt/anaconda3/bin/pip install 'ldap3==2.9'
  chmod u+r /etc/rstudio/database.conf

  # copy pandoc libraries
  ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin

  # setup package managers
  R --slave -e 'install.packages("gert")'
  R --slave -e 'install.packages("usethis")'
  R --slave -e 'install.packages("devtools")'
  R --slave -e 'install.packages("BiocManager")'

  # setup github
  echo "GITHUB_PAT=${PAT}" >> .Renviron
  R --slave -e 'usethis::use_git_config(user.name = "'${USERNAME}'", user.email = "'${EMAIL}'")'
  

  # install r packages via CRAN
  R --slave -e 'install.packages("igraph")'
  R --slave -e 'install.packages("R.utils")'
  R --slave -e 'install.packages("optparse")'
  R --slave -e 'install.packages("reshape2")'
  R --slave -e 'install.packages("plyr")'
  R --slave -e 'install.packages("dplyr")'
  R --slave -e 'install.packages("ggridges")'
  R --slave -e 'install.packages("Seurat")'
  R --slave -e 'install.packages("MatrixEQTL")'
  R --slave -e 'install.packages("mlrMBO")'
  R --slave -e 'install.packages("circlize")'
  R --slave -e 'install.packages("vcfR")'
  R --slave -e 'install.packages("hexbin")'
  R --slave -e 'install.packages("cowplot")'
  R --slave -e 'install.packages("tidyverse")'
  R --slave -e 'install.packages("ggnewscale")'
  R --slave -e 'install.packages("enrichR")'
  R --slave -e 'install.packages("hexbin")'
  R --slave -e 'install.packages("ggpubr")'
  R --slave -e 'install.packages("rmarkdown", dep = TRUE)'
  R --slave -e 'install.packages("ggvenn")'
  R --slave -e 'install.packages("fido")'
  R --slave -e 'install.packages("UpSetR")'
  R --slave -e 'install.packages("sctransform")'
  R --slave -e 'install.packages("compositions")'
  R --slave -e 'install.packages("lmerTest")'
  R --slave -e 'install.packages("nlme")'
  R --slave -e 'install.packages("lme4")'
  R --slave -e 'install.packages("optparse")'
  R --slave -e 'install.packages("MASS")'
  R --slave -e 'install.packages("networkD3")'
  R --slave -e 'install.packages("xlsx")'
  R --slave -e 'install.packages("openxlsx")'
  R --slave -e 'install.packages("scatteR")'
  R --slave -e 'install.packages("statmod")'
  R --slave -e 'install.packages("textTinyR")'
  R --slave -e 'install.packages("pandoc")'
  R --slave -e 'install.packages("irlba")'
  R --slave -e 'install.packages("OlinkAnalyze")'
  R --slave -e 'install.packages("fastR")'
  R --slave -e 'pandoc::pandoc_install()'
  # deprecated package
  R --slave -e 'install.packages("https://cran.r-project.org/src/contrib/Archive/Matrix.utils/Matrix.utils_0.9.8.tar.gz", repos=NULL)'

  # install bioconductor packages
  R --slave -e 'BiocManager::install("MAST")'
  R --slave -e 'BiocManager::install("variancePartition")'
  R --slave -e 'BiocManager::install("edgeR")'
  R --slave -e 'BiocManager::install("BiocParallel")'
  R --slave -e 'BiocManager::install("DESeq2")'
  R --slave -e 'BiocManager::install("VariantAnnotation")'
  R --slave -e 'BiocManager::install("SingleR")'
  R --slave -e 'BiocManager::install("OmnipathR")'
  R --slave -e 'BiocManager::install("ComplexHeatmap")'
  R --slave -e 'BiocManager::install("pcaMethods")'
  R --slave -e 'BiocManager::install("clusterProfiler")'
  #R --slave -e 'BiocManager::install("organism", character.only = TRUE)'
  R --slave -e 'BiocManager::install("organism")'
  R --slave -e 'BiocManager::install("enrichplot")'
  R --slave -e 'BiocManager::install("pathview")'
  R --slave -e 'BiocManager::install("phyloseq")'
  R --slave -e 'BiocManager::install("MOFA2")'
  R --slave -e 'BiocManager::install("muscat")'
  R --slave -e 'BiocManager::install("MetaVolcanoR", eval = FALSE)'
  R --slave -e 'BiocManager::install("UCell")'
  R --slave -e 'BiocManager::install("batchelor")'
  R --slave -e 'BiocManager::install("TOAST")'
  R --slave -e 'BiocManager::install(c("CellBench", "BiocStyle", "scater"))'
  R --slave -e 'BiocManager::install("BuenColors")'
  R --slave -e 'BiocManager::install("Rmpfr")'
  R --slave -e 'BiocManager::install("glmGamPoi")'
  R --slave -e 'BiocManager::install("snpStats")'
  R --slave -e 'BiocManager::install("rhdf5")'

  # Signac prerequisites
  R --slave -e 'BiocManager::install("GenomeInfoDb")'
  R --slave -e 'BiocManager::install("GenomicRanges")'
  R --slave -e 'BiocManager::install("IRanges")'
  R --slave -e 'BiocManager::install("Rsamtools")'
  R --slave -e 'BiocManager::install("S4Vectors")'
  R --slave -e 'BiocManager::install("BiocGenerics")'
  # then signac
  R --slave -e 'install.packages("Signac")'

  # install packages from github
  R --slave -e 'devtools::install_github("immunogenomics/harmony")'
  R --slave -e 'devtools::install_github("sqjin/CellChat")'
  R --slave -e 'devtools::install_github("saeyslab/nichenetr")'
  R --slave -e 'devtools::install_github("JinmiaoChenLab/Rphenograph")'
  R --slave -e 'devtools::install_github("velocyto-team/velocyto.R")'
  R --slave -e 'devtools::install_github(repo = "hhoeflin/hdf5r")'
  R --slave -e 'devtools::install_github(repo = "mojaveazure/loomR", ref = "develop")'
  R --slave -e 'devtools::install_github("pcahan1/singleCellNet")'
  R --slave -e 'devtools::install_github("powellgenomicslab/scPred")'
  R --slave -e 'devtools::install_github("gaospecial/ggVennDiagram")'
  R --slave -e 'devtools::install_github("twbattaglia/MicrobeDS")'
  R --slave -e 'devtools::install_github("buenrostrolab/FigR")'
  R --slave -e 'devtools::install_github("satijalab/seurat-data")'
  R --slave -e 'devtools::install_github("mojaveazure/seurat-disk")'
  #R --slave -e 'devtools::install_github("cnfoley/hyprcoloc", build_opts = c("--resave-data", "--no-manual"), build_vignettes = TRUE)'
  R --slave -e 'devtools::install_github("GreenleafLab/ArchR", ref="dev", repos = BiocManager::repositories())'
  R --slave -e 'devtools::install_github("MarioniLab/miloR", ref="devel")'
  R --slave -e 'devtools::install_github("korsunskylab/rcna")'
  R --slave -e 'devtools::install_github("https://github.com/royoelen/roycols")'
  R --slave -e 'devtools::install_github("https://github.com/royoelen/mdfiver")'
  R --slave -e 'remotes::install_github("cvarrichio/Matrix.utils")'
  R --slave -e 'ArchR::installExtraPackages()'
  R --slave -e 'devtools::install_github("xuranw/MuSiC")'
  R --slave -e 'devtools::install_github("phipsonlab/speckle", build_vignettes = F, repos = BiocManager::repositories())'
  R --slave -e 'remotes::install_github("ludvigla/semla")'
  R --slave -e 'remotes::install_github("chr1swallace/coloc@main",build_vignettes=TRUE)'
  R --slave -e 'devtools::install_github("BIGslu/BIGpicture")'
  R --slave -e 'devtools::install_github("BIGslu/kimma")'
  R --slave -e 'devtools::install_github("BIGslu/RNAetc")'
  R --slave -e 'devtools::install_github("BIGslu/SEARchways")'
  R --slave -e 'devtools::install_github("BIGslu/BIGverse")'
  R --slave -e 'devtools::install_github("https://github.com/molgenis/ReigenMT")'

  # this library is a bit problematic
  export CFLAGS='-mssse3'
  R --slave -e 'remotes::install_github("bnprks/BPCells/r")'

  # Clean up
  rm -rf /var/lib/apt/lists/*

