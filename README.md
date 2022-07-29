# Terraform AWS Starter

## Template development

Please ignore backend generated files from local git first.

```
$ echo 'backend/terraform.tfstate.d/**/terraform.tfstate' >> .git/info/exclude
$ echo 'config/backend.tfvars.*' >> .git/info/exclude
```

## Project development

Make your own .env file from the example:

```
$ cp .env.example .env
```

Make your own variables file by the environment

```
$ cp config/terraform.tfvars.example config/terraform.tfvars.dev
```

Make the backend before init the project:

```
$ ( cd backend && make )
```

Init the project:

```
$ make init
```

Apply infra changes:

```
$ make apply
```

Or simply with single command:

```
$ make
```

~ Happy Coding ~
