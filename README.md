# datasci-quant

This repository contains code to conduct quantitative analysis on stocks in the S&P 500. The focus is on conducting automated fundamental analysis of stocks in a manner that is free of survivorship bias. The objective of these analyses is the creation of investment portfolios that outperform the S&P 500 over the long run - that is, a horizon greater than 5 years.

## Required Resources

1. A computer able to run docker images. You can, as I do, just use github actions to execute your code.
2. An alphavantage API key - you can get a free one, but most of this code only really works well with a 75 calls/minute premium API key.
3. An AWS S3 bucket with the relevant permissions to push and pull data. You could use any S3 compatible object store, such as minio.

## Reproducibile Environment

The code in this repository runs on the docker image generated from the `Dockerfile`, which is built on top of `riazarbi/datasci-gui-minimal`. It's pretty simple, and merely adds R and python libs for quantitative financial analysis.

## Scripts

The various scripts in the root of this repository scrape data sources and store them in a structured manner in AWS S3.

## Functions

The functions in the `R` subdirectory are helper functions to enable the versioned storage of `parquet` formatted datasets in AWS S3.

## Workflows

Pretty much all the code in this repo is executed on a periodic basis via github actions. You can see what actions are run in the `.github/workflows` subdirectory.

