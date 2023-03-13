#!/bin/bash

kube_resource_kind="${1}"
kube_resource_name="${2}"
helm_release_name="${3}"
helm_release_namespace="${4:-default}"

echo "Checking specified resource ..."
if ! kubectl get -n "${helm_release_namespace}" "${kube_resource_kind}" "${kube_resource_name}" >/dev/null; then
    echo 
    echo "Usage: $(basename $0) \"resource kind\" \"resource name\" \"helm release name\" <helm release namespace>"
    exit
fi

echo "Assigning resource ${kube_resource_name} (${kube_resource_kind}) to Helm release ${helm_release_name} (ns: ${helm_release_namespace}) ..."

kubectl patch "${kube_resource_kind}" "${kube_resource_name}" --type=merge -p \
'{
    "metadata": {
        "labels": {
            "app.kubernetes.io/managed-by": "Helm"
        },
        "annotations": {
            "meta.helm.sh/release-name": "'${helm_release_name}'",
            "meta.helm.sh/release-namespace": "'${helm_release_namespace}'"
        }
    } 
}'


#kubectl label image.config.openshift.io cluster "app.kubernetes.io/managed-by=Helm"
#kubectl annotate image.config.openshift.io cluster "meta.helm.sh/release-name=oshift-config-helm"
#kubectl annotate image.config.openshift.io cluster "meta.helm.sh/release-namespace=default"
#kubectl annotate image.config.openshift.io cluster "release.openshift.io/create-only-" 
