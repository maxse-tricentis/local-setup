## General
check_prereqs() {
  for cmd in "$@"
  do
    if ! command -v "$cmd" &> /dev/null
    then
        echo "Command $cmd is not in PATH. Make sure the prerequisites are installed:"
        echo "$@"
        return 1
    fi
  done
  return 0
}
##

## Azure
alias az_aks_list='az aks list --output table --query "[].{name:name, location:location, resourceGroup:resourceGroup, provisioningState: provisioningState}"'
alias az_pipelines_list='az pipelines list --output table --query "[].{name:name, project:project.name, author:authoredBy.uniqueName}"'
alias az_devops_teams_list='az devops team list --output table --query "[].{name:name, project:projectName}"'
alias az_devops_users_list='az devops user list --output table --query "items[].{user:user.principalName, kind:user.subjectKind, lastAccess:lastAccessedDate}"'

az_info() {
  echo 'Azure Cloud'
  az account show --output json --query "{user:user.name, tenant:tenantDefaultDomain, subscription:name}"
  echo '\nAzure DevOps'
  az devops configure -l
}

az_sub() {
  local sub
  local subs

  subs="$(az account list --output table --query "[].{id1:id, name:name, default:isDefault, state:state}")" || return 1
  sub="$(echo "$subs" | sed '1,2d' | gum choose | awk '{print $1}')"
  if [ "$sub" = "" ]
  then
    return 0
  fi

  az account set --subscription="$sub" || return 1
}

az_devops_project() {
  local project
  local projects

  projects="$(az devops project list --output table --query 'value[].[name, visibility, lastUpdateTime]')" || return 1
  project="$(echo "$projects" | sed '1,2d' | gum choose | awk '{print $1}')"
  if [ "$project" = "" ]
  then
    return 0
  fi

  az devops configure -d project="$project" || return 1
}

az_aks_creds() {
  local cluster
  local cluster_name
  local cluster_rg
  local clusters

  if [ -n "$1" ] && [ "$1" != "--admin" ]
  then
    echo "ERROR: Unknown argument $1."
    return 1
  fi

  clusters="$(az aks list --output table)" || return 1
  cluster="$(echo "$clusters" | sed '1,2d' | gum choose)"
  if [ "$cluster" = "" ]
  then
    return 0
  fi
  cluster_name="$(echo "$cluster" | awk '{print $1}')"
  cluster_rg="$(echo "$cluster" | awk '{print $3}')"

  if [ -z "$1" ]
  then
    az aks get-credentials --resource-group "$cluster_rg" --name "$cluster_name" || return 1
  else
    az aks get-credentials --resource-group "$cluster_rg" --name "$cluster_name" --admin || return 1
  fi
}

az_cr_login() {
  local login_info
  local token
  local registry
  local user

  if [ -z "$1" ]
  then
    echo "ERROR: Registry is not set!\n"
    echo 'USAGE: az_cr_login REGISTRY'
    return 1
  fi

  login_info="$(az acr login --name "$1" --expose-token --output tsv 2>/dev/null)" || return 1
  token="$(echo "$login_info" | awk '{print $1}')" || return 1
  registry="$(echo "$login_info" | awk '{print $2}')" || return 1
  user="00000000-0000-0000-0000-000000000000"

  podman login -u "$user" -p "$token" "$registry"
}
##

## MongoDB
mongo_connect() {
  check_prereqs atlas gum curl openssl sed awk date || return 1
  local projects
  local project_id
  local clusters
  local cluster_name
  local username
  local duration_hr
  local delete_after
  local password

  atlas auth login 2> /dev/null

  projects=$(atlas projects list) || return 1
  project_id=$(echo "$projects" | sed '1d' | gum filter --header="Choose the project:" | awk '{print $1}') || return 1
  clusters=$(atlas clusters list --projectId="$project_id") || return 1
  cluster_name=$(echo "$clusters" | sed '1d' | gum filter --header="Choose the cluster" | awk '{print $2}') || return 1
  username="${USER//./}_$(date -u "+%Y%m%dT%H%M%S")" || return 1
  duration_hr="$(gum choose --header 'Remove the access after:' 1H 3H 6H)" || return 1
  delete_after="$(date -u -v"+$duration_hr" '+%Y-%m-%dT%H:%M:%SZ')" || return 1
  password="$(openssl rand -hex 12)"

  atlas dbusers create atlasAdmin --username="$username" --projectId="$project_id" --deleteAfter="$delete_after" -p "$password" || return 1
  atlas accessList create --currentIp --deleteAfter="$delete_after" --projectId="$project_id" || return 1
  echo ''
  atlas clusters connectionStrings describe --projectId="$project_id" "$cluster_name" | sed "s|srv://|srv://${username}:${password}@|g"
}
##

## Random
ananke_set_env_spoke() {
  export AZURE_STORAGE_ACCOUNT='olympiacstate'
  source <(echo -n "export AZURE_PAT_TOKEN='op://Employee/azure_devops_pat/credential'" | op inject)
  source ./src/SharedResources/scripts/pulumi_login.sh --resource-type 'spoke' --az-devops-pat "$AZURE_PAT_TOKEN"
}
##

