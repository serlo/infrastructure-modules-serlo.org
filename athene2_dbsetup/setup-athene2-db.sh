#!/bin/bash

set -e
pod_name="dbsetup-cronjob"
dump_file="dump.zip"
dump_transfer_file="dump_new.zip"

namespace="athene2"

echo "wait for $pod_name to be ready"
until kubectl get pods --all-namespaces | grep $pod_name
do
  sleep 2
done

pod="$(kubectl get pods --namespace $namespace | grep $pod_name | head -n 1 | awk '{ print $1 }')"
kubectl_args="--namespace $namespace"

if kubectl exec -it $pod $kubectl_args -- ls -l /tmp/$dump_file  >/dev/null 2>/dev/null; then
    echo "sql dump already present in dbsetup-cronjob"
else
    if [[ ! -f tmp/$dump_file ]] ; then
        echo "cold not find database dump copy from anonymous-data!"
        gsutil cp gs://anonymous-data/*.zip tmp/$dump_file
    fi
    echo "copy sql dump [tmp/$dump_file] to pod [$pod] args [$kubectl_args]"
    echo kubectl cp tmp/$dump_file $pod:/tmp/${dump_transfer_file} $kubectl_args 
    kubectl cp tmp/$dump_file $pod:/tmp/${dump_transfer_file} $kubectl_args 
    echo "mv sql dump transfer file to final destination to activate import"
    kubectl exec -it $pod --namespace $namespace -- /bin/sh -c "mv /tmp/${dump_transfer_file} /tmp/${dump_file}"
fi
