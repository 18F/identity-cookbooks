# static_eip

The static_eip cookbook provides a recipe to automatically associate the
running instance with a static EIP at startup time using the AWS CLI. This is
similar to the aws-ec2-assign-elastic-ip python library, but unlike that
library it correctly handles race conditions in EIP assignment.

The cookbook loads configuration from a data bag containing the allowed CIDR
blocks from which it can pick EIPs for a given server role.

## Usage

This cookbook defines a single custom resource: `static_eip_assign`. Call this
with the role, environment, and sentinel file (used to ensure that the instance
only attempts to grab an EIP once).
