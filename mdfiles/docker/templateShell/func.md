[首 页](https://patrickj-fd.github.io/index)

---

```shell
#!/bin/bash

BINDIR=$(cd `dirname $0`; pwd)
BUILD_TIME=$(date "+%Y%m%d-%H%M%S")
echo "Current dir  : $BINDIR"
echo "Current time : $BUILD_TIME"

if [ -f envargs.sh ]; then
    . envargs.sh
fi

function echo_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

function echo_warn() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

function echo_info() {
    echo -e "[INFO ] $1"
}

function die(){
    local argInfo="$1"
    echo 
    if [ "Null$argInfo" == "Null" ]; then
        echo_error "Abort !"
    else
        echo_error "$argInfo"
    fi
    echo 
    exit 9
}

function confirm_situation() {
    local car_name="$1"
    local show_lines=${2:=6}
    [ "Null$car_name" == "Null" ] && die "Missing arguments 'car_name' confirm_carlog() !"
    local lg=$(docker logs --tail 5 $car_name)
    if [ "Null$lg" != "Null" ]; then
        # confirm log if having log content
        docker logs --tail $show_lines $car_name
        echo
        echo_warn "<$car_name> startup log as above, is everything OK? "
        read -p "[y/n] " inputKey
        if [ "$inputKey" != "y" ]; then exit 1; fi
    fi
}

function assert_nullvar() {
    msg="$1"
    var_value="$2"
    [ "Null$var_value" == "Null" ] && die "$msg"
}

# $1: IMAGE_NAME
# $2：IMAGE_TAG
function assert_mkimg() {
    local image_name="$1"
    local image_tag="$2"
    [ "Null$image_name" == "Null" ] && die "Missing arguments 'image_name' assert_mkimg() !"
    [ "Null$image_tag" == "Null" ] && die "Missing arguments 'image_tag' assert_mkimg() !"
    local image=$(docker image ls | grep "${image_name}" | grep "${image_tag}")
    if [ "Null$image" == "Null" ]; then
        die "create image <${image_name}:${image_tag}> failed !"
    fi

    echo
    echo "========================================================================"
    echo "create image <${image_name}:${image_tag}> success !"
    echo 
    echo "you can try container:"
    echo "docker container run --rm -it ${image_name}:${image_tag} bash"
    echo 
}

# use this assert if only 'docker container ls' is nothing !
function assert_diedcar() {
    local car_name="$1"
    [ "Null$car_name" == "Null" ] && die "Missing arguments in assert_diedcar() !"
    docker container ls | grep $car_name > /dev/null && return 0
    docker container ls -a | grep $car_name > /dev/null && die "You need clean dying container : $car_name"
}

# show docker logs and confirm 'Continue' Or 'Not' after create container
function confirm_carlog() {
    local car_name="$1"
    local show_lines=${2:=6}
    [ "Null$car_name" == "Null" ] && die "Missing arguments 'car_name' confirm_carlog() !"
    local lg=$(docker logs --tail 5 $car_name)
    if [ "Null$lg" != "Null" ]; then
        # confirm log if having log content
        docker logs --tail $show_lines $car_name
        echo
        echo_warn "<$car_name> startup log as above, is everything OK? "
        read -p "[y/n] " inputKey
        if [ "$inputKey" != "y" ]; then exit 1; fi
    fi
}

# backup docker volumn data. eg: backup postgres's data dir on host computer before redo container
function backup_dir() {
    local dir_name="$1"
    [ "Null$dir_name" == "Null" ] && die "Missing arguments 'dir_name' backup_dir() !"
    [ ! -d "$dir_name" ] && die "<$dir_name> is not dir !"

    local file_middle_name=${2:="backupdata"}

    cur_bkfile=/tmp/hr-docker-$file_middle_name-$(date "+%Y%m%d-%H%M%S").tar.gz
    sudo tar zcfP $cur_bkfile $dir_name || die "backup <$dir_name> to <$cur_bkfile> failed !"
    echo_info "backup <$dir_name> to <$cur_bkfile> successfully !"
}

function load_data_2pgsql() {
    local car_name="$1"
    local sql_file="$2"
    local log_file="$3"
    [ "Null$car_name" == "Null" ] && die "Missing argument(car_name) in load_data_2db() !"
    [ "Null$sql_file" == "Null" ] && die "Missing argument(sql_file) in load_data_2db() !"
    [ "Null$log_file" == "Null" ] && die "Missing argument(log_file) in load_data_2db() !"
    echo "============ $sql_file ============" >> $log_file
    docker container exec $car_name psql -U postgres -f $sql_file >> $log_file 2>&1
    echo -n ".."
}

```

---

[首 页](https://patrickj-fd.github.io)
