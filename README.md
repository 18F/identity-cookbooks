# identity-cookbooks

Common open source cookbooks potentially useful for the community.

**NOTE:** When using these cookbooks, callers will need to put all the recursive dependencies (as listed in the cookbook metadata) in their toplevel Berksfile, since `berkshelf` won't process the Berksfile of dependency cookbooks.
