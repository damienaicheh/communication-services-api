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

## Deploy the Azure Function

```sh
dotnet restore
```

```sh
func azure functionapp publish <functionAppName>
```