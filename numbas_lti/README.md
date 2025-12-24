# Numbas LTI 2025

Instructions for docker here: https://docs.numbas.org.uk/lti/en/latest/installation/docker.html

The helper.sh are included to help with setup.
The LTI would allow instructors to create numbas exam directly on the numbas platform, and share to students. 

The LTI needs to be connected to the Editor, and then the LMS (Moodle) needs to
connect with the LTI as an external tool. 

I have tried to hack my way through to setup all 3 of them locally without a domain name, but it's very hacky, insecure and get blocked by several security measures (csrf, etc.) without official support.

So, I have only tested setting up lti and connecting lti to moodle, which works. Connecting lti to the editor
has too many road blocks while avoiding security issues, so is recommended to try and test with proper domain
and server.