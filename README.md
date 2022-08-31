# Malware Scanning (Severless)

## Running locally

### Prerequisites
- aws-cli
- Docker

- `make run-local` to run localstack and malscanner lambda
- Use aws-cli to upload files to localstack s3 eg. `aws --endpoint=http://localhost:4566 s3 cp file.txt s3://uploads/file.txt`
- Run malware scanner `make scanner-run $payload="{ "Records": [{"s3": { "object": { "key": "file.txt", "size": 1,  "eTag": "string",  "versionId": "string", "sequencer": "string" } } } ] }"`
- Check docker logs

## Deploying to AWS

### Prerequisites
- Terraform
- aws-vault
- aws-cli

### Deployment steps:

- Set AWS_ACCOUNT_ID and AWS_PROFILE in Makefile
- Login to ECR: `make ecr-login`
- Build a new lambda image:  `make new-malscanner-build`
- Deploy changes to AWS `make tf-deploy`. Run `make tf-plan` to verify changes.