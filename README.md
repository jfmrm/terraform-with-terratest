# Terraform with terratest

## Running tests

In order to run the project you must have Terraform 0.14.5 and go 1.15.6 or later.

Before running the tests make sure you have the AMIs built in your aws account, and then replace the ami variables in `/tags-web-erver/main.tf`. This step is imperative due to resource restriction, but in a real world scenario the Packer images would be built by terratest packer module.

To build the images go into `/images/loadbalancer` and `/images/tags-web-server` and run `packer build loadbalancer.pkr.hcl` and `packer build tags-webserver.pkr.hcl` respectivly.

Just go into test folder and run:
```
go test
```

## Project structure
```
/main -> uses modules to create a main environment resources
/modules -> defines simple parametrized modules
/test -> contains tests for main environment
```
