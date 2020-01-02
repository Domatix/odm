# repos clone scripts

## how it works

by calling `cnt -c [CONTAINER] [REPO] [BRANCH]`

```bash
cnt -c odoo12 repos 12.0
```

## how to create a repo script

1. copy the template script

```bash
cp repos/repos.sh.template repo.sh
```

2. open the new file and add your repos inside the `repos` list

```bash

# [...]


# $BRANCH is optional if the desired branch is the repo default
repos=(
        "https://my-git-url.com/repo.git -b $BRANCH"     
        "https://my-git-url.com/repo.git -b $BRANCH" 
)    
```

if some of your repos are private, provide the http username and password inside the `crendentials` dict 
```bash
declare -A crendetials=(
        ["user"]="user"
        ["password"]="pasword"
)
```
