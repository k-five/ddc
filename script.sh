#!/bin/bash

################################################################################
# an associative array for storing color and a function for colorizing
################################################################################
declare -A _colors_;
_colors_[ 'red' ]='\x1b[1;31m';
_colors_[ 'green' ]='\x1b[1;32m';
_colors_[ 'yellow' ]='\x1b[1;33m';
_colors_[ 'cyan' ]='\x1b[1;36m';
_colors_[ 'white' ]='\x1b[1;37m';
_colors_[ 'reset' ]='\x1b[0m';

function colorize(){
    if [[ ${_colors_[ $1 ]} ]]; then
        echo -e "${_colors_[ $1 ]}$2${_colors_[ 'reset' ]}";
    else
        echo 'wrong color name!';
    fi
}

function print_title(){
    echo $(colorize cyan "$@");
}


################################################################################
# __help function
################################################################################
function __help(){
    echo -e  " $0 help ...

 -h | --help            print this help

 -O | --os              OS actions ...
    |                   $(colorize 'cyan' 'type'): show / check the name
    |                   $(colorize 'cyan' 'version'): show / check the version
    |                   $(colorize 'cyan' 'update'): update the OS
    |                   $(colorize 'cyan' 'upgrade'): upgrade the OS
    |                   $(colorize 'cyan' 'info'): more info about OS

 -D | --docker          docker actions ...
    |                   $(colorize 'cyan' 'docker'): try to install docker
    |                   $(colorize 'cyan' 'remove'): try to uninstall docker
    |                   $(colorize 'cyan' 'compose'): try install docker-compose
    |                   $(colorize 'cyan' 'kubectl'): try install kubernetes CLI

 -C | --con
    | --container       container to install (official) ...
    |                   $(colorize 'yellow' 'prometheus'): install prometheus
    |                   $(colorize 'yellow' 'node-exporter'): install node-exporter
    |                   $(colorize 'yellow' 'visualizer'): install docker visualizer
    |                   $(colorize 'yellow' 'portainer-ce'): install portainer-ce
    |                   $(colorize 'yellow' 'grafana'): install grafana

    | --command         Command actions ...
    |                   $(colorize 'white' 'check'): check prerequisites
    |                   $(colorize 'white' 'docker'): check if docker-* have been installed

-R  | --reg
    | --registry        use a mirror registry address
    |                   $(colorize 'white' 'index.docker.io') is the default address

 -P | --port            open a port publicly
    |                   $(colorize 'cyan' 'off'): turn off all firewalls
    |                   $(colorize 'cyan' 'disable'): disable off all firewalls
    |                   $(colorize 'cyan' '[number]'): open this port number

Developer Shakiba Moshiri
source    https://github.com/k-five/ldc"

    exit 0;
}


################################################################################
# if there is no flags, prints help
################################################################################
if [[ $1 == "" ]]; then
    __help;
fi

################################################################################
# check for required commands
################################################################################
function command_check () {
    declare -a _cmds_;
    _cmds_=(curl echo printf chmod install);
    return_code=0;

    for cmd in ${_cmds_[@]}; do
        temp_var=$(which  $cmd > /dev/null 2>&1);
        if [[ $? != 0 ]]; then
            printf "%-20s %s" "$cmd~" "~" | tr ' ~' '. ';
            printf "[ $(colorize 'red' 'ERROR') ] not found\n";
            if [[ $cmd == 'shodan' ]]; then
                echo '>  Please install shodan manually: https://cli.shodan.io/';
            fi
            return_code=1;
        else
            printf "%-20s %s" "$cmd~" "~" | tr ' ~' '. ';
            printf "[ $(colorize 'green' 'OK') ]\n";

        fi
    done
    return $return_code;
}

################################################################################
# check for docker-*
################################################################################
function command_docker () {
    declare -a _cmds_;
    _cmds_=(docker docker-compose docker-machine kubectl);
    return_code=0;

    for cmd in ${_cmds_[@]}; do
        temp_var=$(which  "$cmd" > /dev/null 2>&1);
        if [[ $? != 0 ]]; then
            printf "%-20s %s" "$cmd~" "~" | tr ' ~' '. ';
            printf "[ $(colorize 'red' 'ERROR') ] not found\n";
            if [[ $cmd == 'shodan' ]]; then
                echo '>  Please install shodan manually: https://cli.shodan.io/';
            fi
            return_code=1;
        else
            printf "%-20s %s" "$cmd~" "~" | tr ' ~' '. ';
            printf "[ $(colorize 'green' 'OK') ]\n";

        fi
    done
    return $return_code;
}

function unknown_option(){
    echo "$(colorize red $1) is unknown option for $(colorize 'green' $2)";
    echo "Use '-h' or '--help' to see the available options";
    exit 1;
}


################################################################################
# main flags, both longs and shorts
################################################################################
ARGS=`getopt -o "hO:D:C:R:P:" -l "help,os:,docker:,container:,registry:,command:,port:" -- "$@"`
eval set -- "$ARGS"


################################################################################
# check OS name and version
################################################################################
declare -A  os_support;
os_support['centos']='centos';
os_support['debian']='debian';
os_support['ubuntu']='ubuntu';
os_support['arch']='arch';

os_release=$(tr A-Z a-z < /etc/os-* | egrep -io '(debian|ubuntu|centos|arch)' | uniq | head -n 1);
os_version=$(tr A-Z a-z < /etc/os-* | egrep -i 'version' | grep -Po '\d[^ "]*' | uniq | head -n 1);

declare -A _os
_os['flag']=0;
_os['action']='';

declare -A _docker;
_docker['flag']=0;
_docker['action']='';
_docker['registry']='index.docker.io';

declare -A _container;
_container['flag']=0;
_container['name']='';

declare -A _command;
_command['flag']=0;
_command['action']='';

declare -A _port;
_port['flag']=0;
_port['action']='';
_port['number']=0;
_firewalls=(firewalld iptables ufw);

################################################################################
# check and run _os action
################################################################################
function _os_call(){
    if [[ ${_os['flag']} == 1 ]]; then
        case ${_os['action']} in
            type )
                echo $os_release
            ;;

            version )
                echo $os_version
            ;;

            update )
                case $os_release in
                    centos )
                        print_title "yum -y update";
                        sudo yum -y update;
                    ;;

                    debian )
                        echo 'apt-get -y update'
                    ;;

                    ubuntu )
                        echo 'apt-get -y update'
                    ;;

                    arch )
                        echo 'pacman -Ys update'
                    ;;
                esac
            ;;

            upgrade )
                case $os_release in
                    centos )
                        print_title "yum -y upgrade";
                        sudo yum -y upgrade;
                    ;;

                    debian )
                        echo 'apt-get -y upgrade'
                    ;;

                    ubuntu )
                        echo 'apt-get -y upgrade'
                    ;;

                    arch )
                        echo 'pacman -Ys upgrade'
                    ;;
                esac
            ;;


            info )
                cat /etc/os-*
            ;;

            * )
                unknown_option ${_os['action']} --os;
            ;;
        esac
    fi
}


################################################################################
# check and run _docker action
################################################################################
function _docker_call(){
    if [[ ${_docker['flag']} == 1 ]]; then
        case ${_docker['action']} in
            docker )
                case $os_release in
                    centos )
                        # doc used
                        # https://docs.docker.com/engine/install/centos/#install-using-the-repository
                        print_title "Remove old version of docker"
                        sudo yum remove docker \
                                        docker-client \
                                        docker-client-latest \
                                        docker-common \
                                        docker-latest \
                                        docker-latest-logrotate \
                                        docker-logrotate \
                                        docker-engine;

                         print_title "Install prerequisite for docker"
                         sudo yum install -y yum-utils;

                         print_title "Install dev dependencies";
                         yum clean all;
                         yum groupinstall -y "Development tools";

                         print_title "Add the Docker repository";
                         sudo yum-config-manager \
                                    --add-repo \
                                    https://download.docker.com/linux/centos/docker-ce.repo;

                         print_title "yum -y update after adding docker repo";
                         sudo yum -y update;

                         print_title "install the latest version";
                         sudo yum install -y docker-ce docker-ce-cli containerd.io;

                         print_title "Check if docker group exists";
                         sudo grep docker -io /etc/group
                         if [[ $? != "0" ]]; then
                             print_title "Add docker group";
                             sudo groupadd docker;
                         fi

                         print_title "Add current user to docker group";
                         sudo usermod -aG docker $USER;

                         print_title "Start docker.service";
                         sudo systemctl start docker;

                         print_title "Enable docker.service";
                         sudo systemctl enable docker;

                         print_title "Test docker hello-world";
                         sudo docker run hello-world;
                    ;;

                    debian )
                        echo 'install docker on debian'
                    ;;

                    ubuntu )
                        echo 'install docker on ubuntu'
                    ;;

                    arch )
                        echo 'install docker on arch'
                    ;;
                esac
            ;;

            remove )
                echo "selecting ${_docker['action']}";
            ;;

            compose )
                print_title 'Download docker-compose and save on disk';
                sudo curl -L "https://github.com/docker/compose/releases/download/1.28.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;

                print_title 'Set the permission';
                sudo chmod +x /usr/local/bin/docker-compose;

                print_title 'Add link to /usr/bin';
                sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose;

                echo;
                echo 'reference';
                echo 'https://docs.docker.com/compose/install/';
            ;;

            kubectl )
                print_title 'Download kubernetes and save on disk';
                curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl";

                print_title 'Check the checksum of the file';
                curl -sLO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256";

                print_title 'Validate the kubectl binary against the checksum file'
                echo "$(<kubectl.sha256) kubectl" | sha256sum --check;

                print_title 'Install kubectl';
                sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl;

                print_title 'Add link to /usr/bin';
                sudo ln -s /usr/local/bin/kubectl /usr/bin/kubectl;

                echo;
                echo 'reference';
                echo 'https://kubernetes.io/docs/tasks/tools/install-kubectl/';
            ;;

            * )
                unknown_option ${_docker['action']} --docker;
            ;;
        esac
    fi
}

################################################################################
# check and run _container action
################################################################################
function _container_call(){
    if [[ ${_container['flag']} == 1 ]]; then
        case ${_container['name']} in
            node-exporter )
                # https://hub.docker.com/r/prom/node-exporter
                print_title "docker pull ${_container['name']}";
                docker pull ${_docker['registry']}/prom/node-exporter;
                echo;
                echo 'reference';
                echo 'https://hub.docker.com/r/prom/node-exporter';
                echo 'https://github.com/prometheus/node_exporter';
                echo 'run';
                echo 'docker run -d  -v "/:/host:ro,rslave" --net host --pid host -p 9100:9100   prom/node-exporter  --path.rootfs=/host';
            ;;

            prometheus )
                print_title "docker pull ${_container['name']}";
                docker pull ${_docker['registry']}/prom/prometheus;
                echo;
                echo 'reference';
                echo 'https://hub.docker.com/r/prom/prometheus';
                echo 'https://github.com/prometheus/prometheus';
                echo 'run';
                echo 'docker run --name prometheus -d -p 127.0.0.1:9090:9090 prom/prometheus';
            ;;

            visualizer )
                print_title "docker pull ${_container['name']}";
                docker pull ${_docker['registry']}/dockersamples/visualizer;
                echo;
                echo 'reference';
                echo 'https://github.com/dockersamples/docker-swarm-visualizer';
                echo 'run'
                echo 'docker run -it -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer';
            ;;

            portainer-ce )
                print_title "docker pull ${_container['name']}";
                docker pull ${_docker['registry']}/portainer/portainer-ce;
                echo;
                echo 'reference';
                echo 'https://registry.hub.docker.com/r/portainer/portainer-ce/#!';
                echo 'https://documentation.portainer.io/v2.0/deploy/ceinstalldocker/';
            ;;

            grafana )
                print_title "docker pull ${_container['name']}";
                docker pull ${_docker['registry']}/grafana/grafana:latest;
                echo;
                echo 'reference';
                echo 'https://github.com/grafana/grafana';
            ;;

            * )
                unknown_option ${_container['name']} --container;
            ;;
        esac
    fi
}


################################################################################
# check and run _port_call
################################################################################
function _port_call(){
    if [[ ${_port['flag']} == 1 ]]; then
        case ${_port['action']} in
            off )
                print_title "firewalls are going to be ... ${_port['action']}";
                for cmd in ${_firewalls[@]}; do
                    which $cmd > /dev/null 2>&1;
                        if [[ $? == 0 ]]; then
                             echo "sudo systemctl stop $cmd";
                        fi
                done
            ;;

            disable )
                print_title "firewalls are going to be ... ${_port['action']}";
                for cmd in ${_firewalls[@]}; do
                    which $cmd > /dev/null 2>&1;
                        if [[ $? == 0 ]]; then
                             echo "sudo systemctl disable $cmd";
                        fi
                done
            ;;

            [[:digit:]]* )
                _port['number']=${_port['action']/[a-z]*};
                print_title "allow port number ${_port['action']}";
                for cmd in ${_firewalls[@]}; do
                    which $cmd > /dev/null 2>&1;
                    if [[ $? == 0 ]]; then
                        case $cmd in
                            firewalld )
                                echo "firewall-cmd --zone=public --add-port=${_port['number']}/tcp --permanent";
                                echo "firewall-cmd --reload";
                            ;;

                            iptables )
                                echo "iptables-save > iptables-backup-$(date '+%F-%A-%H-%M-%S')"
                                echo "iptables -I INPUT -p tcp -m tcp --dport ${_port['number']} -j ACCEPT"
                            ;;

                            ufw )
                                echo "ufw allow ${_port['number']}";
                            ;;
                        esac
                    fi
                done
            ;;

            * )
                unknown_option ${_port['action']} --port;
            ;;
        esac
    fi
}


while true ; do
    case "$1" in
        -h | --help )
            __help;
        ;;

        -O | --os )
            _os['flag']=1;
            _os['action']=$2;
            _os_call;
            shift 2;
        ;;

        -D | --docker )
            _docker['flag']=1;
            _docker['action']=$2;
            _docker_call;
            shift 2;
        ;;

        -R | --reg | --registry )
            _docker['registry']=$2;
            shift 2;
        ;;

        -C | --con | --container )
            _container['flag']=1;
            _container['name']=$2;
            _container_call;
            shift 2;
        ;;

        # command
        --command )
            _command['flag']=1;
            _command['action']=$2;
            shift 2;
        ;;

        -P | --port )
            _port['flag']=1;
            _port['action']=$2;
            _port_call;
            shift 2;
        ;;

         -- )
            shift;
            break;
         ;;

         * )
            echo "Internal error!" ;
            exit 1;
         ;;
    esac
done


if [[ ${_command['flag']} == 1 ]]; then
    case ${_command['action']} in
        check )
            echo "Check prerequisites";
            command_check;
        ;;

        docker )
            echo "Check docker-*";
            command_docker;
        ;;

        * )
            unknown_option ${_container['name']} --command;
        ;;
    esac
fi

