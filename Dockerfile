FROM riazarbi/datasci-gui-minimal:20220320203201

LABEL authors="Riaz Arbi"

# Be explicit about user
# This is because we switch users during this build and it can get confusing
USER root

# For arrow to install bindings
ENV LIBARROW_DOWNLOAD=true
ENV LIBARROW_MINIMAL=false

# Install jupyter R kernel
RUN install2.r --skipinstalled --error  --ncpus 3 --deps TRUE -l $R_LIBS_SITE   \
    tidyquant arrow purrr dummies caret
    
# Run as NB_USER ============================================================

USER $NB_USER
