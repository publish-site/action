# Website publishment workflow

This project provides a simple and secure way to deploy a website directly from a Git Repository. It's made to be simple, and easy to configure. For a quick start guide, go [here](https://publish-site.rvid.eu/quick-start).   

At the moment only docker is supported.

The project is split into two repositories, the action (this repo), and the [backend](https://github.com/publish-site/backend/).

You can access a small demo [Here](https://publish-site.rvid.eu/demo/). If you wanna see how the workflow itself is used, go [here](https://github.com/publish-site/docs/actions/workflows/workflow.yml)
[Documentation](https://publish-site.rvid.eu)

## Limitations

* At the moment, the NGINX configuration only allows sites to about 2000M (before compression). This can however be changed in the configuration of the container.
* Non-repudiation (for the server party) and integrity has not been implemented yet.

## License

The project is licensed under The Unlicense.