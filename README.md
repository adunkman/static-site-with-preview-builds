This repository is an example static site with automated preview environments for pull requests that runs on [Amazon Web Services (AWS)](https://aws.amazon.com/).

- The files are stored in an [S3 bucket](https://aws.amazon.com/s3/).
- They are presented to you via [CloudFront](https://aws.amazon.com/cloudfront/), which uses a TLS certificate for https generated and auto-renewed by [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/).
- DNS which points the domain to the appropriate CloudFront distribution is managed by [Route 53](https://aws.amazon.com/route53/).
- The site is built with [Hugo](https://gohugo.io/), but you can change out this static site generator for one of your choosing by editing the files in `site/`.
- All infrastructure changes are automated with [Terraform](https://www.terraform.io/), which is run for the `main` branch only.
- Preview deployments are automatically created for pull requests with [GitHub Actions](https://github.com/features/actions). GitHub Actions also builds and deploys the `main` branch.
- All local development and automated actions in GitHub Actions use [Docker](https://www.docker.com/) to manage installing tools.

## Running locally

1. To get started in development, you’ll need:

    - [Docker](https://www.docker.com/) installed and running.
    - [make](https://www.gnu.org/software/make/) installed and available on your command line. Type `make --version` to check if it’s already installed.

2. Copy `.env.example` to `.env` and configure the environment variables as needed. This file is [automatically read by docker compose](https://docs.docker.com/compose/env-file/).

3. Then, run the following command in the project directory:

    ```bash
    make start
    ```

    - The website will be accessible at [localhost:1313](http://localhost:1313/).
    - The site will live reload on updates to the source files.

4. To quit the command, hit <kbd>Ctrl</kbd>+<kbd>C</kbd>.

### Rebuilding the Docker images

Rebuild the Docker images when you change versions of the installed dependencies:

```bash
make docker-rebuild-site
make docker-rebuild-terraform
```

## Deploying

The site deploys automatically in GitHub Actions, but requires some setup the first time through.

The following steps will configure GitHub Actions with everything it needs to build and deploy both the `main` branch and create preview environments for all other branches.

### Preparing your AWS account and GitHub Actions for Terraform

Terraform will need to run as a user in your AWS account, with permission to administer and modify your account resources as defined in the `terraform/` directory.

1. **Configure a new IAM user** for programmatic access which will be used when running `terraform`. Attach the following existing policies:

    - AmazonDynamoDBFullAccess
    - AmazonS3FullAccess
    - CloudFrontFullAccess
    - AmazonRoute53FullAccess
    - AWSCertificateManagerFullAccess
    - IAMFullAccess
    - AWSWAFFullAccess

2. **Copy the _Access Key ID_ and _Secret Access Key_** to the following locations:

    - **Create a GitHub Actions Environment** in your repository settings named `main`.

        - Set a branch protection rule to allow only the `main` branch to access the environment.
        - Add two environment secrets:
            - `PROD_AWS_ACCESS_KEY_ID` with your _Access Key ID_.
            - `PROD_AWS_SECRET_ACCESS_KEY` with your _Secret Access Key_.

    - **Optionally, configure your local development environment** with these credentials so you can preview and apply changes from terraform. This isn’t needed (since Terraform is run by GitHub Actions) but can help you gain confidence in your changes if you’ll be tweaking the files in the `terraform/` folder.

        - To your `.env` file (copy `.env.example` if you haven’t yet), set:
            - `AWS_ACCESS_KEY_ID` with your _Access Key ID_.
            - `AWS_SECRET_ACCESS_KEY` with your _Secret Access Key_.

3. **Configure GitHub Actions repository secrets** which set project-wide settings. These aren’t strictly secret, but they’ll be used to store configuration values.

    - In your repository settings, set the following repository secrets:
        - `DOMAIN_NAME` to your top-level domain you’ll be hosting at, without `https://` or `www.`.
            - Your preview builds will be accessible at `pr-[PULL_REQUEST_NUMBER].preview.[DOMAIN_NAME]` (for example, `pr-123.preview.example.com`).
            - This should be the same as the `DOMAIN_NAME` configured in `.env` locally.
        - `AWS_DEFAULT_REGION` to the AWS region you’ll be using, like `us-east-1`.

4. **Create Terraform state infrastructure** which Terraform will use to keep track of everything else. In your AWS account:

    - **Create an S3 bucket** named `[DOMAIN_NAME]-terraform`.

        - Enable bucket versioning in case anything happens and you need to restore a previous state file.

    - **Create a DynamoDB table** named `terraform` with Primary key named `LockID` of type `string`.

You’re all set to trigger your first build, which will automatically configure the rest of your AWS account resources and build and upload the static site.

### Enabling preview builds

Now that you’ve configured the `main` branch and run a deploy, Terraform has created a limited-permission deployment account for preview builds.

1. **Head to the AWS IAM console** and find the user named `preview_deployer`.

2. Create an access key for this user on the Security credentials tab.

3. **Copy the _Access Key ID_ and _Secret Access Key_** to the following locations:

    - **Create a GitHub Actions Environment** in your repository settings named `preview`.

        - Add two environment secrets:
            - `AWS_ACCESS_KEY_ID` with your _Access Key ID_.
            - `AWS_SECRET_ACCESS_KEY` with your _Secret Access Key_.

You’re all set! New pull requests will automatically generate preview environments.

## Contributing

Yes please! I’d love to have your contributions to this project — including typo fixes, infrastructure changes, and everything in-between.

- For larger changes, feel free to [open an issue](https://github.com/adunkman/static-site-with-preview-builds/issues/new/choose) to discuss the changes if you’d like to discuss before investing time in it.

Continue reading in [CONTRIBUTING](CONTRIBUTING.md).
