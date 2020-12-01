#!/usr/bin/env bash
#### Written by: Catalin Airimitoaie - catalin@domatix.com
#### Description: ODM main executable file

me=$(basename "$0")
usage="Usage: $me [CONTAINER] [OPTION]...
 This script provides two modes of functionality, via options or positional arguments of a given container.
If the first argument given to this script does not start with a hyphen (-), it will assume you're trying to launch it with the latter functionality

   POSITIONAL ARGUMENTS:
	Usage: $me new|list|<container name>
	
	ARGUMENTS:
		n|ne|new <container name> <odoo version> <port> [postgres docker version]
			create and build a new container with the given options, the postgres docker version is optional since it  defaults to latest

		l|li|lis|list option [--all]
			list status of containers built by this script.
			list all docker containers if --all is specified

		<container name> argument 
			b|boo|boot		boots container
			c|cd path		cds into given path starting at the <container name>
			e|en|ent|ente|enter		opens an interactive bash shell inside <container name> 
				--as user	
				--shell shell
			k|kil|kill		stops <container name>
			s|st|sta|star|start
			u|up|upd|upda|updat|update	updates the odoo version from upstream - git pull

   OPTIONS:
	-n, --new <container name> <odoo version> <port> [postgres docker version]
		create and builds a new container with the given options, the postgres docker version is optional since it  defaults to latest

	-b, --boot [<container name1> <container name2>...] 
		start containers

	-d, --delete [<container name1> <container name2>...] 
		kill and removes containers

	-l, --list 
		list the status of the current built containers

	-s, --start <container name> [<odoo server option 1> <odoo server option 2>...]
		start [CONTAINER]'s Odoo server with [OPTIONS]
		example: $me -s odoo12 -u sale -d base

	-k, --kill <container name>  
		stop the container

	-e, --enter <container name> 
		log into <container name> with a bash shell session

	-r, --run <container name> <user> <command> 
		run <command> inside <container name>

	-c, --clone <container> <script> <version> 
		launch a predefined clone script. see repos/README.md

	-h, --help 
		display this message
"

#### DEFINED PATHS

ROOT=$(dirname "$(readlink -f "$0")")
REPOS=${ROOT}/repos
CONTAINERS=${ROOT}/containers
cd "$ROOT" || exit

#### GLOBALS

ID=$(id -u)

### colors

declare -A color_codes=(["command"]='\e[34m' ["container"]='\e[96m' ["start"]='\e[32m' ["stop"]='\e[31m' ['good']='\e[92m' ['bad']='\e[91m')
wipe='\033[1m\033[0m'

#### PARSER
function parse_positional_arguments() {
  case "$1" in

  n | ne | new)
    shift
    new "$1" "$2" "$3"
    ;;

  l | li | lis | list)
    all=0
    for arg in "$@"; do
      if [[ "$arg" == "--all" ]]; then
        all=1
      fi
    done

    if [[ "$all" == 1 ]]; then
      docker ps -a
    else
      containers=$(ls containers)
      docker ps -a | grep "CONTAINER ID"
      for container in ${containers}; do
        docker ps -a | grep "$container"
      done

    fi
    ;;
  *)
    if container_exists "$1" 1; then
      parse_container_args "$@"
    else
      echo "container ""$1"" does not exist"
    fi
    ;;
  esac
}
function parse_container_args() {
  container="$1"
  shift
  first_level_arg="$1"
  case "$first_level_arg" in
  c | cd)
    change_directory "$container" "$@"
    ;;
  e | en | ent | ente | enter)
    user=
    shell=
    i=0
    # shellcheck disable=SC2124
    args="$@"
    args_list=("$@")
    for arg in ${args}; do
      if [[ "$arg" == "--as" ]]; then
        user=${args_list[$((i + 1))]}
      elif [[ "$arg" == "--shell" ]]; then

        shell=${args_list[$((i + 1))]}
      fi
      i=$((i + 1))
    done
    if [[ -n "$user" ]]; then
      if [[ -n "$shell" ]]; then
        docker exec -it "$container" su -s "$shell" - "$user"
      else

        docker exec -it "$container" su - "$user"
      fi

    else
      docker exec -it "$container" su - odoo
    fi
    ;;
  b | bo | boo | boot)
    boot "$container"
    ;;

  s | st | sta | star | start)
    shift
    start "$container" "$@"
    ;;

  k | ki | kil | kill)
    shift
    kill "$container" "$@"
    ;;
  u | up | upd | upda | updat | update)
    shift
    docker exec -it "$container" git -C /opt/odoo/sources/odoo pull
    ;;

  *)
    help
    ;;
  esac
}
#### FUNCTIONS
function container_exists() {
  if [[ -z "$1" ]]; then
    return 1
  else
    return 0
  fi
}
function help() {
  echo -e "$usage"
}
function change_directory() {
  container="$1"
  shift
  dir="$2"
  cd "$CONTAINERS/$container/custom/$dir" || exit
  exec "$SHELL"
}
function boot() {
  for container in "$@"; do
    echo -e "${color_codes["stop"]}stopping $wipe eventual instance of ${color_codes[container]}$container"
    echo -e "${color_codes["start"]}starting $wipe ${color_codes['container']}$container $wipe"
    cd "$CONTAINERS"/"$container" || exit
    docker-compose up -d
  done
}
function delete() {
  for container in "$@"; do

    echo "This will delete all containers associated with this instance, including the postgres, and its files."
    echo "Are you sure you want to proceed [y/N]?"
    local delete='n'
    read -r delete
    case "$delete" in
    y | Y)
      cd "$CONTAINERS"/"$container" 2>/dev/null || echo -e "${color_codes[container]} ${container} $wipe does not exist" || exit
      echo -e "${color_codes["stop"]}stopping $wipe ${color_codes[container]}$container"
      docker-compose down
      rm -rf "${CONTAINERS:?}/${container:?}"
      ;;
    *)
      echo "${container} was not deleted"
      ;;
    esac
  done
}
function start() {
  container=$1
  shift
  echo -e "starting  ${color_codes[container]}$container's Odoo server $wipe"
  docker exec -it "$container" runuser odoo -c 'cd; cd custom/etc; kill -9 $(cat run.pid)'
  local ARGS="$*"
  local ETC="/opt/odoo/custom/etc"
  docker exec -it "$container" runuser odoo -c "cd; $ETC/generate-conf.sh; $ETC/run-odoo.sh $ARGS"
}
function run() {
  container=$1
  shift
  user=$1
  echo -e "running ${color_codes[command]}$* $wipe into ${color_codes[container]}$container $wipe via $user"
  shift
  local array=("$@")
  local len=${#array[@]}
  args=${array[*]:0:${len}}
  docker exec -it "$container" runuser "$user" -c "$args"
}
function clone() {
  container=$1
  repo=$2
  branch=$3
  if [[ -f "$REPOS/$repo.sh" ]]; then
    echo -e "launching clone script ${color_codes["good"]} $repo.sh $wipe"
    "$ROOT"/repos/"$repo".sh "$CONTAINERS"/"$container" "$branch"
  else
    echo -e "repo script ${color_codes["bad"]} $repo.sh $wipe does not exist"
  fi
}
function kill() {
  echo -e "stopping $1"
  cd "$CONTAINERS"/"$1" || exit
  docker-compose stop
  echo -e "$1 stopped"
}
function update() {
  echo -e "stopping $1"
  echo -e "starting $1"
  echo -e "starting the odoo server and updating $2"
  start "$1" "$2"
}
function new() {
  CONTAINER="$CONTAINERS/$1"
  if [[ ! -d "$CONTAINER" ]]; then
    ODOO_VERSION="$2"
    PORT="$3"
    POSTGRESQL_VERSION="${4:-latest}"
    env_template="odoo_version=$ODOO_VERSION\nid=$ID\ncontainer_name=$1\nport=$PORT\naddons_path=$CONTAINER/custom/addons\ndata_path=$CONTAINER/custom/data\netc_path=$CONTAINER/custom/etc\nsources_path=$CONTAINER/custom/sources\npostgres_version=$POSTGRESQL_VERSION"
    mkdir -p "$CONTAINER"/custom/{sources,etc,addons,data}
    cp templates/template.conf "$CONTAINER"/custom/etc/odoo.conf
    echo -e "$env_template" >"$CONTAINER"/.env
    cp templates/docker-compose.yml "$CONTAINER"/docker-compose.yml
    cp dockerfiles/custom/Dockerfile "$CONTAINER"/Dockerfile
    ./build.sh "$CONTAINER"
    git clone --depth=1 --branch="$ODOO_VERSION" https://github.com/odoo/odoo.git "$CONTAINER"/custom/sources/odoo || exit 1
    boot "$1"
    run "$1" root chown -R odoo:odoo /opt/odoo/sources/odoo || exit 1
    run "$1" odoo virtualenv -p python3.6 /opt/odoo/sources/odoo/env || exit 1
    PIPYENV="/opt/odoo/sources/odoo/env/bin/pip"
    run "$1" odoo "$PIPYENV" install -r /opt/odoo/sources/odoo/doc/requirements.txt || exit 1
    run "$1" odoo "$PIPYENV" install -r /opt/odoo/sources/odoo/requirements.txt || exit 1
    run "$1" odoo "$PIPYENV" install phonenumbers xmlsig workdays numpy unidecode zeep pandas || exit 1
    echo -e "
You can now ${color_codes['good']} boot $wipe the newly created container by typing:\n
	$0 -b $1\n
And ${color_codes['good']} start $wipe the Odoo server with:\n
	$0 -s $1\n"
  else
    echo "The container already exists"
  fi
}

##### ARGUMENTS PARSER

case "$1" in
-n | --new)
  shift

  if [[ -z "$1" ]]; then
    help
  fi

  new "$@"

  ;;
-b | --boot)
  shift
  boot "$@"
  ;;
-c | --clone)
  shift
  clone "$@"
  ;;
-d | --delete)
  shift
  delete "$@"
  ;;

-s | --start)
  shift
  start "$@"
  ;;

-r | --run)
  shift
  run "$@"
  ;;

-u | --update)
  shift
  update "$@"
  ;;

-k | --kill)

  kill "$2"
  ;;
-e | --enter)
  shift
  user="odoo"
  if [[ -n "$2" ]]; then
    user=$2
  fi
  docker exec -it "$1" su - "$user"
  ;;

-l | --list)
  docker ps -a
  ;;
-h | --help)
  help
  ;;
*)
  if [[ -z "$1" ]]; then
    help
  else
    parse_positional_arguments "$@"
  fi
  ;;

esac
