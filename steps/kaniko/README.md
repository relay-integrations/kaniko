# Kaniko

This Kaniko step container runs the Kaniko image builder.

## Specifications

| Setting | Child setting | Data type | Description | Default | Required |
|-----------|------------------|-----------|-------------|---------|----------|
| `destination` || string | The destination repository to push the image to after building. | None | True |
| `context` || string | The directory within the specified Git repository to use as the Docker context | `/` | False |
| `buildArgs` || mapping | A mapping of build argument names to values to pass to the build. | None | False |
| `dockerfile` || string | Within the specified `context` directory, the path to the Dockerfile to build. | `Dockerfile` | False |
| `git` || mapping |  | A map of git configuration. If you're using HTTPS, only `name` and `repository` are required. | None | False |
|| `ssh_key` | string | The SSH key to use when cloning the git repository. You can pass the key to Nebula as a secret. See the example below. | None | True |
|| `known_hosts` | string | SSH known hosts file. Use a Nebula secret to pass the contents of the file into the workflow as a base64-encoded string. See the example below. | None | True |
|| `name` | string | A directory name for the git clone. | None | True |
|| `branch` | string | The Git branch to clone. | `master` | False |
|| `repository` | string | The git repository URL. | None | True |

> **Note**: The value you set for a secret must be a string. If you have multiple key-value pairs to pass into the secret, or your secret is the contents of a file, you must encode the values using base64 encoding, and use the encoded string as the secret value.

## Examples

Here is an example of the step in a Nebula workflow:

```YAML
steps:

...

- name: kaniko
  image: projectnebula/kaniko:latest
  spec:
    context: deploy
    buildArgs:
      ALPINE_VERSION: '3.6'
    destination: gcr.io/my-repo/my-image:latest
    git: 
      ssh_key:
        $type: Secret
        name: ssh_key
      known_hosts:
        $type: Secret
        name: known_hosts
      name: my-git-repo
      branch: dev
      repository: path/to/your/repo
```