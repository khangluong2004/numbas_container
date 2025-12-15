# Numbas Container 2025

Using docker instead of vm to start-up numbas: https://docs.docker.com/ 

There apparently is already an image built here: https://github.com/numbas/numbas-editor-docker.git 
https://hub.docker.com/r/numbas/numbas-editor

It was done 6 years ago, and many packages have been out-dated and no longer supported. So, following the latest instruction, I build this container.

## Files overview

1. compose.yml: Set up for container startup (with port forwarding, ...)
2. Dockerfile: Set up instructions to build the numbas container image.
3. numbas_install.sh: Bash file for installing packages in building docker's image.
4. startup.sh: Script to setup db users and first set up, before starting the web server.
5. web_setup.sh: Helper script used in startup.sh to set up the web server.

## Instruction

1. Install Docker
2. Supply the editor password in the .env file. Create an .env file at the top level
following this format:
```bash
EDITOR_PASSWORD=<editor_password>
```
3. Run:
```bash
docker compose up --build
```
to build and start the server container.

4. The first setup requires opening a webpage on http://localhost:8000. Go to this page,
set up the correct access domain (leave it as * to allow any domain),
select MySQL as the desirable database (as setup following Numbas' instruction), 
input the database's editor use password as set in step 2, and leave all others as default.
Click Next and wait until the setup process are finished.

If this is not the first setup (eg: an old docker container is just restarted), skip step 4 and move to step 5.

5. The log will display the process id (pid) of the setup server (as that requires
a web server for some reason), like this:
```
numbas_editor  | Run "first setup" script
numbas_editor  | Running first setup in background with PID <pid of setup process>
```

Open a new terminal, and run:
```bash
docker compose exec numbas_container kill <pid of setup process>
``` 
to kill the setup server and allow the scripts to continue.

6. The numbas editor will be ready on port 8080.
