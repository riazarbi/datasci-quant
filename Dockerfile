FROM riazarbi/datasci-gui-minimal:20211230082307

LABEL authors="Riaz Arbi"

# Be explicit about user
# This is because we switch users during this build and it can get confusing
USER root

# Install jupyter R kernel
RUN install2.r --skipinstalled --error  --ncpus 3 --deps TRUE -l $R_LIBS_SITE   \
    tidyquant arrow
    
# Run as NB_USER ============================================================

USER $NB_USER
