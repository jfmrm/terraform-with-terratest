# Terraform with terratest

## Running tests

In order to run the project you must have Terraform 0.14.5 and go 1.15.6 or later.
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
