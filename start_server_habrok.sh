#!/bin/bash
mkdir -p ${TMPDIR}/rstudio-server-logging
mkdir -p ${TMPDIR}/etc
mkdir -p ${TMPDIR}/tmp
mkdir -p ${TMPDIR}/server-data
mkdir -p ${TMPDIR}/lib
echo "www-port=8777" > ${TMPDIR}/etc/rserver.conf
singularity run  --bind \
/home3/${USER}/singularity/rstudio-server/simulated_home:/home/${USER},\
/home3/${USER}/singularity/rstudio-server/simulated_home:/home3/${USER},\
/scratch/${USER}/,\
${TMPDIR},\
${TMPDIR}/rstudio-server-logging:/var/run/rstudio-server,\
${TMPDIR}/lib:/var/lib/rstudio-server,\
${TMPDIR}/etc:/etc/rstudio,\
${TMPDIR}/tmp:/tmp \
/home3/${USER}/singularity/rstudio-server/singularity-rstudio.simg \
--server-user ${USER} \
--server-data-dir ${TMPDIR}/server-data/ \
--server-daemonize 0 \
--secure-cookie-key-file ~/server-data/rserver_cookie
