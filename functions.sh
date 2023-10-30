#!/bash/bin

# VARS:
# Lower case Target Group name => used for URL group path references
target_group=$(echo $TARGET_GROUP | tr '[:upper:]' '[:lower:]')

function login() {

# input is "source" or "target"
REMOTE=$1
if [ ${REMOTE} == "source"  ]
then
# Ost Gitlab:
    export GITLAB_TOKEN=$SOURCE_GITLAB_TOKEN
    export GITLAB_HOST=$SOURCE_GITLAB_HOST
elif [ ${REMOTE} == "target" ]
then
# Ace Gitlab:
    export GITLAB_TOKEN=$TARGET_GITLAB_TOKEN
    export GITLAB_HOST=$TARGET_GITLAB_HOST
else 
  echo 'invalid input => "source" or "target" are accepted' 
  exit 1
fi
glab auth login --hostname $GITLAB_HOST --token $GITLAB_TOKEN
}

function clone_source_group() {
# This function uses glab to clone all projects and subgroups for the source host:
login source
mkdir projects
cd projects
glab repo clone -g $SOURCE_ROOT_GROUP -p --paginate
}

function generate_source_project_list() {
echo "GENERATE_SOURCE_PROJECT_LIST"
echo "======================================="
# This function generates a list of projects in a group and outputs it to a text file.
# This file can then be filtered/edited to generate the final list as input for projects migrated to the target
login source
source_array=( $(glab api /groups/$SOURCE_ROOT_GROUP/projects?include_subgroups=true --paginate  | jq '.[] | {path_with_namespace} | join(" ")' | tr -d '"') )
source_subgroup_array=( $(glab api /groups/$SOURCE_ROOT_GROUP/subgroups --paginate | jq '.[] | {name} | join (" ")' | tr -d '"') )
# project_array=( $(glab api /groups/$SOURCE_ROOT_GROUP/projects?include_subgroups=true | jq '.[] | {path_with_namespace} | join(" ")' | tr -d '"' ) )
for i in ${!source_array[@]} 
do
  echo ${source_array[$i]} >> source_list.txt
done
for i in ${!source_subgroup_array[@]} 
do
  echo ${source_subgroup_array[$i]} >> source_subgroup_list.txt
done
read -p "Press edit the project and subgroup list to your liking. Press any key to continue with project migration:" input
echo "======================================="
}


function create_target_groups() {
echo "CREATE_TARGET_GROUPS"
echo "======================================="
# This functions creates the group and subgroup structure on the target host:
login target

# List Groups:
# curl "https://$GITLAB_HOST/api/v4/groups" --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" | jq '.[]'

# Get Parent ID of TARGET_PARENT_GROUP:
PARENT_ID=$(curl "https://$GITLAB_HOST/api/v4/groups" --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" | jq --arg group_name "$TARGET_PARENT_GROUP" '.[] | select( .name == $group_name ) | {id} | join (" ")' | tr -d '"' )
echo $PARENT_ID

# Create TARGET_GROUP from TARGET_PARENT_GROUP:
curl "https://$GITLAB_HOST/api/v4/groups" --request POST --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}"  --header "Content-Type: application/json" --data "{\"path\" : \"$target_group\" , \"name\" : \"$TARGET_GROUP\" , \"parent_id\" : \"$PARENT_ID\"}"

# Get Parent ID of TARGET_GROUP for creating further subgroups:
PARENT_ID=$(curl "https://$GITLAB_HOST/api/v4/groups" --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" | jq --arg group_name "$TARGET_GROUP" '.[] | select( .name == $group_name ) | {id} | join (" ")'  | tr -d '"' )

# Create further subgroups:
readarray -t source_subgroup_array < source_subgroup_list.txt
for i in ${!source_subgroup_array[@]} 
do
  # Create subgroups:
  SUBGROUP=${source_subgroup_array[$i]}
  echo $SUBGROUP
  echo $PARENT_ID
  curl "https://$GITLAB_HOST/api/v4/groups" --request POST --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}"  --header "Content-Type: application/json" --data "{\"path\" : \"$SUBGROUP\" , \"name\" : \"$SUBGROUP\" , \"parent_id\" : \"$PARENT_ID\"}"  
done
echo "======================================="
}


function migrate_projects() {
echo "MIGRATE_GROUP"
login target
# Rename SOURCE_ROOT_GROUP to TARGET_GROUP and generate target_list.txt:
readarray -t source_array < source_list.txt
for i in ${!source_array[@]} 
do
R=$(echo ${source_array[$i]} | cut -d"/" -f2- ) 
echo $target_group/$R >> target_list.txt
done

readarray -t target_array < target_list.txt
cd projects
mv $SOURCE_ROOT_GROUP $target_group
for i in ${!target_array[@]} 
do
  echo "========================================"
  echo "MIGRATING PROJECT $i OF ${#target_array[@]}" 
  PROJECT_PATH=${target_array[$i]}
  PROJECT_DIR=$(dirname ${target_array[$i]})
  PROJECT=$(basename ${target_array[$i]})

  echo "PROJECT_PATH=$PROJECT_PATH"
  echo "PROJECT_DIR=$PROJECT_DIR"
  echo "PROJECT=$PROJECT"
  echo "__________________________________________________________________"
  echo n | glab repo create --group ddm-dev/$PROJECT_DIR $PROJECT
  CURRENT_DIR=$(pwd)
  cd $PROJECT_PATH
  git remote rename origin source
  git remote add origin https://${TARGET_GITLAB_HOST}/${TARGET_PARENT_GROUP}/${PROJECT_PATH}.git
  for remote in `git branch -r `; do git checkout --track remotes/$remote ; done
  git push origin --all
  cd $CURRENT_DIR
  echo "======================================="
done
echo "========================================"
}

function cleanup() {
echo "CLEANUP"
echo "======================================="
rm -rf projects
echo "======================================="
}