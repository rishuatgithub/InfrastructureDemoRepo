- The **terraform state** can be saved remotely using backend functionality in remote.
- The default is **local backend**.
- Other backends include:
  - **S3** (with a locking mechanism using dynamodb)
  - **consul** (with locking)
  - **terraform enterprise** (commercial solution)

- There are 2 steps to configure a remote state:
  - Add a backend code to a .tf file
  - Run the initialisation process

