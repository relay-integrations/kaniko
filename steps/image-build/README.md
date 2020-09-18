# kaniko-step-image-build

This Kaniko step container runs the Kaniko image builder.

## Examples

Here is an example of the step in a Nebula workflow:

```YAML
steps:

...

- name: kaniko
  image: relaysh/kaniko-step-image-build
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