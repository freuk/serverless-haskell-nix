## Serverless Haskell via Nix and Docker

Following a late 2020 [feature announcement](https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/),
serverless Haskell became easy.

This repository builds a Docker image ready to be pushed to ECR for use in AWS
Lambda. It weighs 43MB, well below AWS's announced 10G limit, embeds all its
dependencies down to glibc, and has a reproducible build.

This example uses Oleg Grenrus'
[AWS Runtime](https://github.com/phadej/aws-lambda-haskell-runtime)
implementation.

```
docker load <$(nix-build -A lambda-container)
```

Pointers:
- https://lazamar.github.io/deploying-statically-linked-haskell-to-lambda/
- https://www.haskelltutorials.com/haskell-aws-lambda/compiling-haskell-runtime-in-docker.html
