This is the script used to create the minteirb iso.

## How to use

After cloning the repo, insert a ubuntu iso (tested with ubuntu 24.04 LTS) inside the `iso` folder.
Afterwards, run:

```sh 
docker compose up; docker compose down
```

This will create and run a docker which will create a minteirb iso.
When finished, the iso will be in the `new-iso` folder.
