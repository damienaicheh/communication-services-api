# Demo for connecting APIM with Azure Function calling ACS

## Deploy the environment

```sh
cd terraform && terraform init
```

```sh
terraform plan -out plan.out
```

```sh
terraform apply "plan.out"
```