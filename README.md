# notejamAssignment
This repository contains the code necessary to deploy the notejam application on the AWS cloud. For more information about the application refer [notejam](https://github.com/nordcloud/notejam)

## Prerequisites:
| Tool | Reference |
| ------ | ------ |
| eksctl | [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) |
| terraform | [terraform](https://www.terraform.io/downloads.html) |
| aws-cli | [aws](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) |

## Variables that can be edited
| VariableName | Description |
| ------ | ------ |
| eksCommonConfig | Common configuration for the cluster  |
| eksPublicSubnets | Public Subnet for eks control plane |
| eksPrivateSubnets | Private Subnets for the worker nodes  |
|eksClusterInfo| eks cluster control plane parameters|
|eksClusterNodeGroupInfo| eks cluster NodeGroup parameters|
|eksClusterNodeGroupScalingInfo| eks cluster NodeGroup auto scaling information|
|rdsInfo|rds data base parameters, disable rds if database cluster is deployed as the statefuls sets in the eks|

## Deployment procedure
- Edit the variables.tf file with the parameters of the cluster
- Edit the variables in the backend.tf with the aws credentials else set the below environment variables. For more details on how to pass the access credentials refer [aws-provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
```sh
$ export AWS_ACCESS_KEY_ID=<AWS Access Key Id>
$ export AWS_SECRET_ACCESS_KEY=<AWS Access Key>
$ export AWS_DEFAULT_REGION=<AWS region id>
```
- Terraform uses the Amazon S3 backend to lock the state files to prevent  multiple users to use at the same time. Configure the backend in the backend.tf file.
**NOTE: The bucket and the dynamoDB table should be created before hand**
- Run the below command to initialize the terraform providers.
  ```sh
   $ terraform init
   ```
- Run the below command to see the set of resources that are created.
  ```sh
  terraform plan
  ```
- If aeverything looks fine then proceed with the deployment with the below command.
    ```sh
  terraform apply --auto-approve
  ```
## Destroying the Infrastructure
The infrastructure can be deployed with the below command.
 ```sh
 terraform destroy --auto-approve
 ```
 
## Resources Created
|Resource|Discription|
|----|----|
|vpc| For the networking of the EKS cluster|
|Public Subnets| Subnets for the kubernetes cluster in multiple availability zones|
|Internetgateway| For the the EKS cluster to be reachable from the internet|
|Private Subnets|Subnets for the kubernetes worker nodes in multiple availability zones|
|Nat gateway| For the workernodes to reach the internet|
|Routing Tables | For the network traffic to route|
|Security Groups| For the Private and public subnet access|
|ALB Controller | CNI for creation of services with loadbalancer type|
|CSI Controller| For creating the persistent storage for the pods|
|Roles| For the pods to create AWS resources|
|EKS cluster|For deploying the application|
|EKS worker nodes | For the kubernetes worker nodes|

## Deploying the notejam application

### With RDS 

RDS is a production grade database instance which supports multiple database engines, it is completely managed by the AWS and all the OS patches and maintainance is taken care by the AWS. It also supports multiAZ deployments, when deployed AWS guarantees the High Availability. For more information on the RDS, refer [RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html). Using this is highly recommended for production use.

When enabled in the variable.tf, it is deployed as an infrastructure component. Just use it when deploying the application.

To deploy the nodejam application with the RDS, set the **SQLALCHEMY_DATABASE_URI** in the kubernetes/noteJamApp.yml file and run the below command.
```sh
kubernetes apply -f kubernetes/noteJamApp.yml
```

### Deploy notejam with database as microservice
- Deploy the mysql stateful set with the below command.
   ```sh
   kubectl apply -f kubernetes/mysql-statefulset.yaml
   ```

- Once the mysql pods are up and running, deploy the application using the below command.
  ```sh
  kubernetes apply -f kubernetes/noteJamApp.yml
  ```

### Accessing the application

To get the URL to access the application run the below command.

```sh
kubectl get svc -n notejam
```

### Scaling the application

To scale the application run the below command to check the current replicas of the application.

```sh
kubectl get deployments -n notejam
```
Run the below to scale the application.

```sh
kubectl deployments scale notejam --replicas=<desired number of instances>
```

**NOTE: Specifying a number less than the running instances will scale down the application**

## Deleting the Application
To delete the application run the below commands

```sh
kubectl delete -f kubernetes/mysql-statefulset.yaml
kubernetes delete -f kubernetes/noteJamApp.yml
```
