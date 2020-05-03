# Go Microservice

Build, test and deploy a toy Golan microservice by means of GitHub actions on a self-hosted runner. For simplicity both the runner and the application are running in the same namespace (*actions-runner-system*).

## Choose the tool

The code is hosted on GitHub, so I decided to give a shot to their CI/CD tool, with one main point. I'd like to avoid the GitHub-hosted runners and deploy my own on a Kubernetes cluster (Minikube on my laptop).

An [operator](https://github.com/summerwind/actions-runner-controller) is available: the documentation is clear, the setup is not complicated and the token used to communicate with GitHub is in a Kubernetes secret (other operators required to bake it into the base image).

**Time spent**: about 2 hours to read the documentation, try the alternatives and do a basic setup

### Cluster setup

**Base folder**: `setup`

Terraform is being used to prepare the Kubernetes cluster. The state is in a local file instead of a bucket on the cloud. Concurrent access is not an issue here. Terraform is meant to run locally. The target Kubernetes cluster is also local. Two files are needed:

* `provider_config.tf`: setup the Terraform provider for Kubernetes. It reads the `~/.kube/config` file to talk to the Minikube cluster running locally;
* `setup.tf`: it creates the Kubernetes resources, namely:
	* the namespace
	* a role to allow the management of deployments and services
	* a role binding assigning the above mentioned role to the default account of the namespace.

**Time spent**: 30 minutes (some trial and error to find the right verbs and API groups).

### GitHub self-hosted runner operator

**Base folder**: `setup`

A GitHub token for the project has been created according to the [instrucitons](https://github.com/summerwind/actions-runner-controller#using-personal-access-token) and a secret has been created manually (otehrwise the token would remain in plain text in the Terraform state file)

```
kubectl create secret generic controller-manager --from-literal=github_token=<token>
```

The deployment of the operator is very easy, it's documented [here](https://github.com/summerwind/actions-runner-controller#installation). The operator manifest has been saved as `actions-runner-controller.yml`, deployed as

```
kubectl apply -f actions-runner-controller.yml
```

The deployment of the actual runner is described in the file `deployment.runner.yml`. The only customisation is the repo name. The command for the deployment

```
kubectl apply -f deployment.runner.yml
```

**Time spent**: 45 minutes

## The application

The application is a HTTP listener in Golang which prints the string *Hello, World* when receiving a GET request. All other method are rejected. 

The code is in `main.go`. It has been found online, but reworked to make it testable.

The unit tests are in `main_test.go`. 

**Time spent**: 1 hour.

## The pipeline

**Base folder**: `.github.workflows`

The workflow setup is in the file `go.yml`. The available actions from the [marketplace](https://github.com/marketplace?type=actions) have been used as much as possible.


## kubectl setup

setup kube config with sa token: [here](https://dev.to/richicoder1/how-we-connect-to-kubernetes-pods-from-github-actions-1mg)

* the secret is `/var/run/secrets/kubernetes.io/serviceaccount/token`
* the CA cert is `/var/run/secrets/kubernetes.io/serviceaccount/ca.crt`