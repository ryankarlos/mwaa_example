#!/bin/bash

while getopts i:a:r: flag
do
    case "${flag}" in
        i) image_tag=${OPTARG};;
        a) account_id=${OPTARG};;
        r) region=${OPTARG};;
    esac
done
echo "Image Tag required: $image_tag";
echo "Account ID: $account_id";
echo "AWS Region: $region";

aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$account_id".dkr.ecr."$region".amazonaws.com
docker build -t "$image_tag" .
docker tag "$image_tag":latest "$account_id".dkr.ecr."$region".amazonaws.com/"$image_tag":latest
docker push "$account_id".dkr.ecr."$region".amazonaws.com/"$image_tag":latest