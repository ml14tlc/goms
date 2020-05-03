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

Few notes about some steps:

* *Docker build and push*: instead of building the application on the runner and pass it as artifact, I preferred to use a multi-stage Docker file. Unfortunately the unit tests (see the step *Unit tests*) 
requires *Set up Go 1.13*, which is rather costly in terms of download, so at this point it boils down to personal preference;
* *Deploy*: the deployment of the application on the cluster relies on a marketplace action. The drawback is that the configuration file for `kubectl` is required, passed as a secret. It has been generated according to [these](https://dev.to/richicoder1/how-we-connect-to-kubernetes-pods-from-github-actions-1mg) instructions. The solution is not ideal, I tried to use a [service container](https://help.github.com/en/actions/configuring-and-managing-workflows/about-service-containers) to run `kubectl proxy`. It would have taken care of the authentication, so no need to pass keep track of the static credentials. Unfortunately it didn't work out of the box, so I opted for an easier solution;
* *Integration test*: this is rather simple, it only calls the URL of the app's service via CURL. Only the method GET is supported. Tests in a real case should be more complicated, probably a script would be better than this simple action.

**Time spent: 3 hours**