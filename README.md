# TextXD Hub Deployment

This repo has all the information and scripts for [https://jupyter.textxd.org/](https://jupyter.textxd.org/).

- `bootstrap.sh` can be used to boot it up from scratch if for whatever reason that's necessary.
- `config.yaml.template` is the most current config file for the JupyterHub. *It should always be updated to the most recent helm upgrade*. This `bootstram.sh` script will automatically generate a `config.yaml` which should never be committed (it is listed in .gitignore)
- `destroy.sh` will tear down the hub and all its resources.
