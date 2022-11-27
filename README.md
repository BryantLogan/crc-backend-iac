# Backend repository for the Cloud Resume Challenge
I created this fullstack project based on the [Cloud Resume Challenge](https://cloudresumechallenge.dev/), utilizing AWS.

The frontend portion of this project can be found in this [repository](https://github.com/BryantLogan/crc-frontend-https). The deployed web app can be found [here](https://bryantlogan.com).
## Backend diagram
![This is an image](/backend-infra.png)
## The infrastructure
The backend is built with IaC (Terraform) to provision an API Gateway, Lambda function, and DynamoDB. Whenever the web app is accessed, a JavaScript function makes an API call to the API Gateway. This call then triggers the Lambda function to access an item in the DynamoDB table, adds +1 to the visit count attribute, and returns the updated value in the response. The current visit count is then displayed at the bottom of the web page.

## CI/CD
The backend uses GitHub Actions to deploy any changes in the Terraform configuration files any time code is pushed to this repository. The workflow will also run end to end Cypress tests on the API Gateway to make sure the Lambda function is returning usable data.