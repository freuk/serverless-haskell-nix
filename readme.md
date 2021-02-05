## Serverless Haskell via Nix

Here are two ways to ship Haskell to AWS Lambda. The first method bundles shared libraries only, which is appropriate due to the [quota](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html) from AWS on lambda function size. The second methods leverages the larger quota on container size to bundle the whole set of Nix dependencies, which is more robust.

- Using a custom runtime. Build output 3MB, quota 50MB. Bundles only shared libraries, uses `patchelf` and bootstraps with a `LD_LIBRARY_PATH` overwrite.
  ```
  $ nix-build -A zip -o lambda.zip
  # push file "./lambda.zip" to AWS Lambda with the method of your choice
  ```

- Using a container (see late 2020 [feature announcement](https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/)). Build output 43MB, quota 10GB. Bundles all Nix dependencies.
  ```
  $ docker load <$(nix-build -A container)
  # push image "lambda:nix" to AWS ECR with Docker
  # trigger an AWS Lambda update with the method of your choice
  ```

Both examples package the `toUpper` example function contained in `Main.hs`, which uses Oleg Grenrus'
[AWS Runtime implementation(https://github.com/phadej/aws-lambda-haskell-runtime)
.

The implementation for the patching in `lambda-zip` is adapted from Renzo Carbonara's
[code](https://github.com/k0001/aws-lambda-nix-haskell).
