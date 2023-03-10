#!/bin/bash
kubectl label image.config.openshift.io cluster "app.kubernetes.io/managed-by=Helm"
kubectl annotate image.config.openshift.io cluster "meta.helm.sh/release-name=oshift-config-helm"
kubectl annotate image.config.openshift.io cluster "meta.helm.sh/release-namespace=default"
kubectl annotate image.config.openshift.io cluster "release.openshift.io/create-only-" 
