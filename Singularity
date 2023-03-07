BootStrap: docker
From: ubuntu:20.04

%labels
  Maintainer Jeremy Nicklas, Roy Oelen
  RStudio_Version 0.91.10

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
  export RSTUDIO_VERSION=2022.07.0-548

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
    libhdf5-serial-dev \
    libboost-all-dev
  apt-get install -y libudunits2-dev
  apt-get install -y libgdal-dev
  apt-get install -y libgsl-dev

  # install cuda toolkit
  # https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_local
  export DEBIAN_FRONTEND=noninteractive
  wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
  mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
  wget https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda-repo-ubuntu2004-12-1-local_12.1.0-530.30.02-1_amd64.deb
  dpkg -i cuda-repo-ubuntu2004-12-1-local_12.1.0-530.30.02-1_amd64.deb
  cp /var/cuda-repo-ubuntu2004-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/
  apt-get update
  apt-get -y install cuda

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
    "https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb"
  gdebi -n rstudio-server.deb
  rm -f rstudio-server.deb

  # Add support for LDAP authentication
  wget \
    --no-verbose \
    -O get-pip.py \
    "https://bootstrap.pypa.io/get-pip.py"
  python3 get-pip.py
  rm -f get-pip.py
  pip3 install 'ldap3==2.9'
  chmod u+r /etc/rstudio/database.conf

  # set the server directory to be in /home, because the container is not writeable
  echo "directory=~/rstudio-server" >> /etc/rstudio/database.conf

  # install r packages
  R --slave -e 'install.packages("devtools")'
  R --slave -e 'install.packages("BiocManager")'

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

  R --slave -e 'install.packages("https://cran.r-project.org/src/contrib/Archive/Matrix.utils/Matrix.utils_0.9.8.tar.gz", repos=NULL)'

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

  # manual stuff
  wget https://www.r-tutor.com/sites/default/files/rpud/rpux_0.7.2_linux.tar.gz
  tar -xf rpux_0.7.2_linux.tar.gz
  cd rpux_0.7.2_linux
  R --slave -e 'install.packages("rpud_0.7.2.tar.gz")'
  R --slave -e 'install.packages("rpudplus_0.7.2.tar.gz")'

  # Clean up
  rm -rf /var/lib/apt/lists/*
