# Linux Docker Configuration

## How to install
```bash
 curl  -sL 'https://raw.githubusercontent.com/k-five/ldc/master/script.sh' -o /usr/local/bin/ldc
 chmod u+x !$
 ```
Then you can run it and see the output:
 ```bash
# see the help
>  ldc --help
```

## Usage without installing it:

### run --help
```bash
> bash <(curl -sL 'https://raw.githubusercontent.com/k-five/ldc/master/script.sh') --help
```

### update os
```bash
> bash <(curl -sL 'https://raw.githubusercontent.com/k-five/ldc/master/script.sh') --os update
```

### update os , install docker, install node-exporter and prometheus
```bash
> bash <(curl -sL 'https://raw.githubusercontent.com/k-five/ldc/master/script.sh') --os update --docker docker --con node-exporter --con prometheus
```

## or simpler
```bash
> alias ldc='bash <(curl -sL 'https://raw.githubusercontent.com/k-five/ldc/master/script.sh')'

# check help
> ldc --help

# update the OS
> ldc --os update

# update the OS, install Docker, install prometheus form default registry
> ldc --os update --docker docker --con node-exporter --con prometheus

# update the OS, install Docker, install node-exporter and prometheus from a docker.mirror.derak.cloud
> ldc --os update --docker docker --reg docker.mirror.derak.cloud --con node-exporter --con prometheus
```

## bash tab completion
If you use / set the script with and **alias** or **install** it with `ldc` name, then you can use bash tab completion feature.
For more about bash tab completion you can read [Bash Tab Completion script for common CLIs](https://github.com/redcursor/btc).

### load it just-in-place
```bash
> source <(curl -sL https://raw.githubusercontent.com/redcursor/btc/master/ldc/_comp_ldc.sh)
> ldc <HIT-TAB>
```

### or install it
```bash
> curl -sL https://raw.githubusercontent.com/redcursor/btc/master/ldc/_comp_ldc.sh -o /etc/bash_completion.d/_comp_ldc.sh
> source !$
> ldc <HIT-TAB>
```
