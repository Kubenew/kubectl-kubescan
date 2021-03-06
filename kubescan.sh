#!/bin/bash
#define the variables
kubectl version --short | awk -Fv '/Server Version: / {print $3}';kubectl config view;kubectl get all
KUBE_LOC=~/.kube/config
#define variables
KUBE=$(which kubectl)
GET=$(which egrep)
AWK=$(which awk)
red=$(tput setaf 1)
normal=$(tput sgr0)
# define functions
info()
{
  printf '\n\e[34m%s\e[m: %s\n' "INFO" "$@"
}

fatal()
{
  printf '\n\e[31m%s\e[m: %s\n' "ERROR" "$@"
  exit 1
}

checkcmd()
{
  #check if command exists
  local cmd=$1
  if [ -z "${!cmd}" ]
  then
    fatal "check if kubectl is installed !!!"
  fi
}

print_table()
{
  #prepare the ground
  first=$(echo -n "$@"|cut -d'|' -f1)
  second=$(echo -n "$@"|cut -d'|' -f2)
  third=$(echo -n "$@"|cut -d'|' -f3)
  sizeoffirst=$((${#first} + 5))
  sizeofsecond=${#second}
  printf "\n\e[1m%s\e[0m\t\e[32m%s\e[0m" "POD_NAME      " "${first}"
  printf "\n\e[1m%s\e[0m\t\e[32m%s\e[0m" "CONTAINER_NAME" "${second}"
  printf "\n\e[1m%s\e[0m\t\e[32m%s\e[0m" "ERRORED       " "${third}"
  printf '\n'
}

get_namespaces()
{
  #get namespaces
  namespaces=( \
          $($KUBE get namespaces --ignore-not-found=true | \
          $AWK '/Active/ {print $1}' \
          ORS=" ") \
          )
#exit if namespaces are not found
if [ ${#namespaces[@]} -eq 0 ]
then
  fatal "No namespaces found!!"
fi
}

#get events for pods in errored state
get_pod_events()
{
  printf '\n'
  if [ ${#ERRORED[@]} -ne 0 ]
  then
      info "${#ERRORED[@]} errored pods found."
      for CULPRIT in ${ERRORED[@]}
      do
        info "POD: $CULPRIT"
        info
        $KUBE get events \
        --field-selector=involvedObject.name=$CULPRIT \
        -ocustom-columns=LASTSEEN:.lastTimestamp,REASON:.reason,MESSAGE:.message \
        --all-namespaces \
        --ignore-not-found=true
      done
  else
      info "0 pods with errored events found."
  fi
}

#define the logic
get_pod_errors()
{
  for NAMESPACE in ${namespaces[@]}
  do
    info "SCANNING FOR ERRORED PODS AND CONTAINERS logs, Namespace: ${red}$NAMESPACE${normal}"
    printf '\n'
    while IFS=' ' read -r POD CONTAINERS
    do
      for CONTAINER in ${CONTAINERS//,/ }
      do
        COUNT=$($KUBE logs --since=1h --tail=20 $POD -c $CONTAINER -n $NAMESPACE 2>/dev/null| \
        $GET -c '^error|Error|ERROR|Warn|WARN')
        if [ $COUNT -gt 0 ]
        then
            STATE=("${STATE[@]}" "$POD|$CONTAINER|$COUNT")
        else
        #catch pods in errored state
            ERRORED=($($KUBE get pods -n $NAMESPACE --no-headers=true | \
                awk '!/Running/ {print $1}' ORS=" ") \
                )
        fi
      done
    done< <($KUBE get pods -n $NAMESPACE --ignore-not-found=true -o=custom-columns=NAME:.metadata.name,CONTAINERS:.spec.containers[*].name --no-headers=true)
  done
}
#define usage for seprate run
usage()
{
cat << EOF
  USAGE: "${0##*/} </path/to/kube-config>(optional)"
EOF
exit 0
}

#check if basic commands are found
checkcmd KUBE
#
#set the ground
if [ $# -lt 1 ]; then
  if [ ! -e ${KUBE_LOC} -a ! -s ${KUBE_LOC} ]
  then
    info "A readable kube config location is required!!"
    usage
  fi
elif [ $# -eq 1 ]
then
  export KUBECONFIG=$1
elif [ $# -gt 1 ]
then
  usage
fi
#play
get_namespaces
get_pod_errors

printf '\n%40s\n' 'KUBESCAN'
printf '%s\n' '---------------------------------------------------------------------------------'
printf '%s\n' '  KUBESCAN is a command line utility to scan pods and prints name of errored pods   '
printf '%s\n\n' ' +and containers within. To use it as kubernetes plugin, please check their page '
printf '%s\n' '================================================================================='

cat results.csv | sed 's/,/,|/g'| column -s ',' -t
get_pod_events
