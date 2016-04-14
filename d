#!/bin/bash
# current directory name
name=${PWD##*/}
if [ -f vars ]
then
    source vars
fi
imagename=$name:latest
c_exists() {
    if sudo docker ps -a | grep -q $name; then
        return 1
    else
        return 0
    fi
}
c_running() {
    if sudo docker ps | grep -q $name; then
        return 1
    else
        return 0
    fi
}
save() {
    c_exists
    if [ $? -eq 1 ]; then
       sudo docker save $imagename | pxz > $name.tar.xz
    fi
}
i_exists() {
    if sudo docker images | grep -q $name; then
        return 1
    else
        return 0
    fi
}
build() {
    sudo docker build -t $imagename .
}
kill() {
    c_running
    if [ $? -eq 1 ]; then
        stop
    fi
    c_exists
    if [ $? -eq 1 ]; then
        sudo docker rm $name
    fi
}
wipe() {
    kill
    i_exists
    if [ $? -eq 1 ]; then
        sudo docker rmi $imagename
    fi
}
start() {
    i_exists
    if [ $? -eq 0 ]; then
        build
    fi
    c_exists
    if [ $? -eq 1 ]; then
        sudo docker start $name
    else
        ./run $name
    fi
}
stop() {
    sudo docker stop $name
}
jump() {
    c_running
    if [ $? -eq 0 ]; then
        start
    fi
    sudo docker exec -it $name bash
}
status() {
    i_exists
    if [ $? -eq 1 ]; then
        echo 'image exists'
        c_running
        if [ $? -eq 1 ]; then
            echo 'container exists, running'
        else
            c_exists
            if [ $? -eq 1 ]; then
                echo 'container exists, not running'
            else
                echo 'container does not exist'
            fi
        fi
    else
        echo 'image does not exist'
    fi
}
$1
