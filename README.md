# Demo for connecting APIM with Azure Function calling ACS

## Deploy the environment

```sh
cd terraform && terraform init
```

Set the subscription ID as an environment variable:
```sh
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

```sh
terraform plan -out plan.out
```

```sh
terraform apply "plan.out"
```

## Deploy the Azure Function

```sh
dotnet restore
```

```sh
func azure functionapp publish <functionAppName>
```
