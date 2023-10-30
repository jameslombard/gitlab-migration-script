#!/bash/bin
# Login Creds
# SOURCE => TARGET
export SOURCE_GITLAB_HOST=
export SOURCE_GITLAB_TOKEN=
export TARGET_GITLAB_HOST=
export TARGET_GITLAB_TOKEN=



# SOURCE_GROUP_CONFIG:
export SOURCE_ROOT_GROUP=""
# Note: This group must be at the root level of the source Gitlab instance. 

export TARGET_PARENT_GROUP=""
# NOTE: All SOURCE_ROOT_GROUP projects and subgroups are migrated to this TARGET_PARENT_GROUP.  
# This goup must exist/be-created before-hand on the target Gitlab instance.

# Defined name of TARGET_GROUP where all projects and subgroups of the SOURCE_ROOT_GROUP are migrated to:
# The default values is the same as the SOURCE_ROOT_GROUP name, but can be newly defined here:
export TARGET_GROUP=$SOURCE_ROOT_GROUP

# Config Output:
echo "CONFIG"
echo "======================================="
echo "SOURCE_GITLAB_HOST"=$SOURCE_GITLAB_HOST
echo "TARGET_GITLAB_HOST"=$TARGET_GITLAB_HOST
echo "SOURCE_ROOT_GROUP"=$SOURCE_ROOT_GROUP
echo "TARGET_PARENT_GROUP"=$TARGET_PARENT_GROUP
echo "TARGET_GROUP="$TARGET_GROUP
echo "======================================="
