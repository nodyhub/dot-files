#!/bin/bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT_FILE=dfiles.tar.gz

# Define the directory setup command
REMOVE_DIRS_CMD="rm -rf ~/.zsh/{lib,plugins}"
SETUP_DIRS_CMD="mkdir -p ~/.zsh/{lib,plugins,custom} ~/.zsh/lib/{aliases,completion,core,exports,functions,git,history,keymap,prompt,tools}"

# Create .hushlogin file to disable "Last login" message
HUSHLOGIN_CMD="touch ~/.hushlogin"

# Define the extract command with directory setup
EXTRACT_CMD="$REMOVE_DIRS_CMD ; cd ~ ; tar xzf $DOT_FILE -C . ; rm $DOT_FILE ; $SETUP_DIRS_CMD ; $HUSHLOGIN_CMD"

echo [+] Fetch ZSH and VIM plugins
git submodule init
git submodule update

echo [+] Prepare zipfile $BASEDIR/$DOT_FILE
if [ -f $BASEDIR/$DOT_FILE ]
then
	rm $BASEDIR/$DOT_FILE
fi
tar -c --exclude-from exclude.lst  -zf $BASEDIR/$DOT_FILE .

if [ -f remote-hosts ]
then
    echo [+] Iterate over destinations

    # Read hosts into an array in a way that works in most bash versions
    hosts=()
    while IFS='' read -r line || [[ -n "$line" ]]; do
        [[ ! -z "$line" ]] && hosts+=("$line")
    done < "$BASEDIR/remote-hosts"

    for i in "${hosts[@]}"
    do
       echo [+] Deploy on $i
       home_dir=$(ssh "$i" pwd)
       scp $BASEDIR/$DOT_FILE $i:$home_dir/$DOT_FILE
       echo [+] dot-files transfered
       ssh $i "$EXTRACT_CMD"
       echo [+] data extracted at $i:$home_dir
    done
else
    echo [!] No 'remote-hosts' found, Skip!
fi

echo [+] Deploy local
cp $BASEDIR/$DOT_FILE ~/$DOT_FILE
eval "$EXTRACT_CMD"
rm $BASEDIR/$DOT_FILE

echo [+] Finished
exit 0
