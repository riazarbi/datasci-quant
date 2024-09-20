FROM riazarbi/datasci-gui-minimal:20240920203039

LABEL authors="Riaz Arbi"

# Be explicit about user
# This is because we switch users during this build and it can get confusing
USER root

# For arrow to install bindings
ENV NOT_CRAN=true

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get clean && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y \
    libsodium-dev \
# Clean out cache
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/*

# Install jupyter R kernel
RUN install2.r --skipinstalled --error  --ncpus 3 --deps TRUE -l $R_LIBS_SITE   \
    tidyquant arrow purrr caret diffdfs leaps blastula WikipediR

RUN R -e "remotes::install_github('riazarbi/r-dummies', dependencies = TRUE)"
RUN R -e "remotes::install_github('riazarbi/dataversionr', dependencies = TRUE, ref = '0.9.1')" 

# GITHUB ACTIONS FIX ========================================================
RUN mkdir /github \
 && mkdir /__w \
 && chown -R jovyan /github /__w \
 && chmod -R 777 /github /__w

# Run as NB_USER ============================================================

USER $NB_USER
