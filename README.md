# Numbas Container 2025

There apparently is already an image built here: https://github.com/numbas/numbas-editor-docker.git 
https://hub.docker.com/r/numbas/numbas-editor

It was done 6 years ago, so I'll put the entire thing into legacy, and also build 
following the latest instruction for the container (as the legacy seems to take forever to build for some reason).

Supply the editor password as environment variable during runtime:

```bash
docker run -e EDITOR_PASSWORD=$EDITOR_PASSWORD myimage
```
