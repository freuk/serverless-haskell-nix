## Serverless Haskell via Nix

Here are two ways to leverage Nix for reproducible serverless haskell by bundling dependencies all the way down to glibc.

- Using a custom runtime. Build output 3MB, quota 50MB. Loads dependencies via
  `LD_LIBRARY_PATH` overwrite.
  ```
  nix-build -A zip -o lambda.zip
  # push "lambda.zip" to AWS Lambda with method of your choice
  ```

- Using a container. Build output 43MB, quota 10GB. Late 2020 [feature announcement](https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/).
  ```
  docker load <$(nix-build -A container)
  # push "lambda:nix" to AWS ECR with method of your choice and trigger update
  ```

Both examples package the same function, which uses Oleg Grenrus'
[AWS Runtime](https://github.com/phadej/aws-lambda-haskell-runtime)
implementation, and indeed file `Main.hs` simply contains an example of his.

The implementation for the patching in `lambda-zip` is adapted from Renzo Carbonara's
[code](https://github.com/k0001/aws-lambda-nix-haskell).

Note that functions `lambda-zip` and `lambda-container` are not specific to
Haskell. They should work with any executable build output that is properly
packaged.
