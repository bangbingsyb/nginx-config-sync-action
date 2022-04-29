# nginx-config-sync-action

## Move a tag to a different commit

```
git tag -d <tagname>                  # delete the old tag locally
git push origin :refs/tags/<tagname>  # delete the old tag remotely
git tag <tagname> <commitId>          # make a new tag locally
git push origin <tagname>             # push the new local tag to the remote
```

## Add execute mode permissions to the shell script
```
git update-index --chmod=+x /src/deploy-config.sh
``` 