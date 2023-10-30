# Gitlab Migration Utility

This utility uses bash functions, glab and the gitlab API to migrate Gitlab projects from one instance to another, based on their group and subgroup structure. 

## Steps

The conf.sh script requires setting the following ENV_VARS:

- SOURCE_GITLAB_HOST
- SOURCE_GITLAB_TOKEN
- TARGET_GITLAB_HOST
- TARGET_GITLAB_TOKEN
- SOURCE_ROOT_GROUP
- TARGET_PARENT_GROUP
- TARGET_GROUP

The meaning of the variables are explained in the comments within conf.sh.

Once these valuesa are set, the migration script is run as follows:

`./main.sh`

The main.sh script sources the ENV_VARS from conf.sh and the bash functions from functions.sh, and runs the main migration script steps:

main.sh :

``` bash

#!/bin/bash

# Ref: https://gitlab.com/gitlab-org/cli#environment-variables

# Note: the glab config file is in ~/.config/glab-cli/config.yml
# protocol is set at host level as follows:
#      token: 
#      api_host: <gitlab-url>
#      git_protocol: https
#      api_protocol: https
#      user: <username>

source conf.sh
source functions.sh

clone_source_group
generate_source_project_list
create_target_groups
migrate_projects
cleanup
```

