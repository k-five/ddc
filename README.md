# Linux Docker Configuration

## How to install
```bash
 curl  -sL 'https://raw.githubusercontent.com/k-five/ldc/master/script.sh' -o /usr/bin/ldc
 chmod u+x !$
 ```

 then we should be able to run `ldc` and see the output:
 ```bash
  /usr/bin/ldc help ...

 -h | --help            print this help

    | --os              OS actions ...
    |                   type: show / check the name
    |                   version: show / check the version
    |                   update: update the OS
    |                   upgrade: upgrade the OS
    |                   info: more info about OS

    | --docker          docker actions ...
    |                   install: try to install docker
    |                   uninstall: try to uninstall docker
    |                   compose: try install docker-compose
    |                   kubectl: try install kubernetes CLI

    | --con
    | --container       container to install ...
    |                   prometheus: install prometheus
    |                   node-exporter: install node-exporter
    |                   visualizer: install docker visualizer
    |                   portainer-ce: install portainer-ce

    | --port            open a port publicly

Developer Shakiba Moshiri
source    https://github.com/k-five/ldc
```

## Usage without installing it:

### run --help
```bash
bash <(curl -sL 'https://raw.githubusercontent.com/k-five/ldc/master/script.sh') --help
```

### update os
```bash
bash <(curl -sL 'https://raw.githubusercontent.com/k-five/ldc/master/script.sh') --os update
```

### update os , install docker, install node-exporter and prometheus
```bash
bash <(curl -sL 'https://raw.githubusercontent.com/k-five/ldc/master/script.sh') --os update --docker docker --con node-exporter --con prometheus
```

## or simpler
```bash
alias ldc='bash <(curl -sL 'https://raw.githubusercontent.com/k-five/ldc/master/script.sh')'

# check help
ldc --help

# update the OS
ldc --os update

# update the OS, install Docker, install prometheus form default registry
ldc --os update --docker docker --con node-exporter --con prometheus

# update the OS, install Docker, install node-exporter and prometheus from a docker.mirror.derak.cloud
ldc --os update --docker docker --reg docker.mirror.derak.cloud --con node-exporter --con prometheus
```
