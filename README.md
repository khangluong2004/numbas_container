# Numbas Container 2025
## Overview
The Numbas editor is used to create questions and exams.
However, in order to host the exams for student to access, an LMS is required
(eg: Moodle, Canvas, etc.) to store the score, record the attempts, etc. Numbas 
exam/questions can then be connected/incorporated into the LMS.

For Moodle, Numbas exam can be:

1. Download as a SCORM package and upload to Moodle (via Quiz -> Add Activity -> Add SCORM package).

2. Set up Numbas LTI ("Learning Tools Interoperability is a standard which defines how a Tool consumer connects to a tool providing a learning activity") and server.
Then connect Numbas server to the LMS, and students can then attempt the exam via
the LMS. This allows more flexibility than option 1 (eg: educators can change
the exam without reuploading the SCORM package).

The first method is fully tested, and works fine. The second method is not tested yet,
because of security reasons (and requirements of servers, domain, etc. for set up), so is
recommended for actual production only.

## Numbas Editor
All details in /numbas_editor README

## Numbas LTI
All details in /numbas_lti README