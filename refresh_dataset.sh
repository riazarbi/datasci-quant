SCRIPT=$1

docker run --rm \
-v /home/riaz/projects/datasci-quant:/home/jovyan/datasci-quant \
-v /home/riaz/projects/secrets.json:/home/jovyan/secrets.json \
-v /data/quant:/data/quant \
--entrypoint '/bin/bash' \
riazarbi/datasci-quant:20220817142717 \
-c "cd datasci-quant && Rscript -e 'source(\"set_env.R\"); source(\"$SCRIPT\")'"
