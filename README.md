# Numbas Container 2025

Using docker instead of vm to start-up numbas: https://docs.docker.com/ 

There apparently is already an image built here: https://github.com/numbas/numbas-editor-docker.git 
https://hub.docker.com/r/numbas/numbas-editor

It was done 6 years ago, and many packages have been out-dated and no longer supported. So, following the latest instruction, I build this container.

## Instruction

1. Install Docker
2. Supply the editor password in the .env file. Create an .env file at the top level
following this format:
```bash
EDITOR_PASSWORD=<editor_password>
```
3. Run:
```bash
docker compose run --service-ports numbas_container
```
for an interactive shell during setup.
4. Follow the prompts (access the server in )
