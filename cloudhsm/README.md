# cloudhsm

The `cloudhsm` cookbook provides recipes for installing cloudhsm client
libraries, discovering cloudhsm clusters, and setting up client configuration.

It is built to work with AWS CloudHSM v2.

## Usage

The custom resource `cloudhsm_config` is the primary entrypoint. Call this
resource with the cluster ID or name tag.
