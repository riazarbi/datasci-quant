FROM riazarbi/datasci-gui-minimal:20220820203457

LABEL authors="Riaz Arbi"

# Be explicit about user
# This is because we switch users during this build and it can get confusing
USER root

# For arrow to install bindings
ENV NOT_CRAN=true

# Install jupyter R kernel
RUN install2.r --skipinstalled --error  --ncpus 3 --deps TRUE -l $R_LIBS_SITE   \
    tidyquant arrow purrr caret diffdfs leaps

RUN R -e "remotes::install_github('riazarbi/r-dummies', dependencies = TRUE)"
RUN R -e "remotes::install_github('riazarbi/dataversionr', dependencies = TRUE)" 

# Run as NB_USER ============================================================

USER $NB_USER
