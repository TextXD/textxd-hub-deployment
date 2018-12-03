# TextXD Hub Deployment

This repo has all the information and scripts for [https://jupyter.textxd.org/](https://jupyter.textxd.org/).

- The `notes` folder has various notes we've taken as we've set up the resources and may help in debugging or trouble shooting issues.
- `Dockerfile.jhub` is the Dockerfile *for the JupyterHub* and *not for the single user*. It's short, because it just adds the custom OAuthenticator.
- `bootstrap.sh` can be used to boot it up from scratch if for whatever reason that's necessary.
- `config.yaml` is the most current config file for the JupyterHub. *It should always be updated to the most recent helm upgrade*.
- `destroy.sh` will tear down the hub and all its resources.
- `user-metrics.ipynb` is a first attempt at gathering metrics from volumes hosted on Google Cloud.
