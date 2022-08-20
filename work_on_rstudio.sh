#!/bin/bash


folder=datasci-quant
IMAGE=riazarbi/datasci-quant:20220817142717

docker pull $IMAGE

echo "Starting disposable container mounted on /home/$USER/projects/$folder"
    docker run -it --rm \
    --name=$folder \
    -v /home/$USER/projects/$folder:/home/jovyan/$folder \
    -v /home/$USER/projects/lofi-portfolio:/home/jovyan/lofi-portfolio \
    -v /data/quant:/data/quant \
    -v /home/$USER/projects/secrets.json:/home/jovyan/secrets.json: \
    -v /tmp:/tmp \
    -e NB_UID=$UID \
    -p 8888:8888 \
    --user root \
    -e CHOWN_HOME=yes \
    -e CHOWN_HOME_OPTS='-R' \
    -e GRANT_SUDO=yes \
    -e JUPYTER_ENABLE_LAB=yes \
    $IMAGE /bin/bash start-notebook.sh --NotebookApp.default_url="/rstudio" --no-browser --NotebookApp.token="" --ip="0.0.0.0"
