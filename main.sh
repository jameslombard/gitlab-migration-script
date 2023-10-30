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