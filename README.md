# gsm
git ssh manager - tell git which private key to use 

# what is it?
> I created this tool because I needed to use different ssh keys to access git repositories

To use specific ssh key while performing git cli there command you need to do this
```shell
git config --global core.sshCommand "ssh -i <path-to-key>";
```
or this 
```shell
GIT_SSH_COMMAND = "ssh -i <path-to-key>"  git ...
```

This tools simplifies this experience to :
```shell
gsm use <name>;
git ...
```
This sets saves preferred ssh key file path in git global config `core.sshCommand` until you change it.

You can add existing keys with user-friendly names with `gsm add` and chose which one to use with `gsm use`

```



