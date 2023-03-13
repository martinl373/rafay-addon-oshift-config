# Cluster Scoped CRDs and Helm Adpot Issue

## 1. Install CRDs
These CRDs are from the Kyverno service. We do not install Kyverno nor use it in any way.
We are only borrow one cluster scoped and one namespace scoped CRD from it as a test. (can be anything really)

```bash
kubectl create -f test-setup/crds/sample-custom-crds.yaml
```

## 2. Install the Inital versions of test resources

```bash
for file in test-setup/manifests/*; do
    kubectl create -f ${file}
done
```

## 3. Try to run the helm chart now
This should fail with Helm complaining that it does not own the files.

```bash
helm upgrade --install test-release test-chart/
```

## 4. Ready all resources for Helm adoption
This is a official feature of helm since version 3.2ish.

```bash
scripts/helm-adopt.sh image.config.openshift.io cluster test-release
scripts/helm-adopt.sh clusterpolicy.kyverno.io test-clusterpolicy test-release
scripts/helm-adopt.sh policy.kyverno.io test-policy test-release
scripts/helm-adopt.sh clusterrole.rbac.authorization.k8s.io test-clusterrole test-release
scripts/helm-adopt.sh role.rbac.authorization.k8s.io test-role test-release
scripts/helm-adopt.sh configmap test-configmap test-release
```

## 5. Run helm again and BOOM borked!
Now all will seem to run, Helm will even say it have x resources to update, but some of them
will just be silently not changed. This can be run over and over. And helm will not actually do
anything until the files in the helm chart changes AFTER the initial adoption.

```bash
helm upgrade --install test-release test-chart/
```

Looking at the output from Helm in debug mode (Adding the `--debug` flag) one can see that helm actually thinks that these files are not different (in cluster vs chart)

```
client.go:396: [debug] checking 6 resources for changes
client.go:684: [debug] Patch ConfigMap "test-configmap" in namespace default
client.go:684: [debug] Patch ClusterRole "test-clusterrole" in namespace
client.go:684: [debug] Patch Role "test-role" in namespace default
client.go:675: [debug] Looks like there are no changes for ClusterPolicy "test-clusterpolicy"
client.go:675: [debug] Looks like there are no changes for Image "cluster"
client.go:675: [debug] Looks like there are no changes for Policy "test-policy"
```

## Results
| Resource Type | Changed? |
|---|---|
| image.config.openshift.io | false |
| clusterpolicy.kyverno.io  | false |
| policy.kyverno.io         | false |
| clusterrole.rbac.authorization.k8s.io | true |
| role.rbac.authorization.k8s.io | true |
| configmap | true |
