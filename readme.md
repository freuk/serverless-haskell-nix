## Serverless Haskell via Nix

Here are two ways to leverage Nix for AWS Lambda compatible reproducible haskell builds. The first method only adds shared libraries, which is appropriate due to the quota. The second methods bundles the whole set of Nix dependencies.  

- Using a custom runtime. Build output 3MB, quota 50MB. Loads only linked runtime dependencies, uses `patchelf` and bootstraps with a `LD_LIBRARY_PATH` overwrite.
  ```
  $ nix-build -A zip -o lambda.zip
  # push file "./lambda.zip" to AWS Lambda with the method of your choice
  ```

- Using a container (see late 2020 [feature announcement](https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/)). Build output 43MB, quota 10GB. Bundles all the dependencies.
  ```
  $ docker load <$(nix-build -A container)
  # push image "lambda:nix" to AWS ECR with Docker
  # trigger an AWS Lambda update with the method of your choice
  ```

Both examples package `Main.hs`, which uses Oleg Grenrus'
[AWS Runtime](https://github.com/phadej/aws-lambda-haskell-runtime)
implementation.

The implementation for the patching in `lambda-zip` is adapted from Renzo Carbonara's
[code](https://github.com/k0001/aws-lambda-nix-haskell).
