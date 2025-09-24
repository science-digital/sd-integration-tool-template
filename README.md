# Sciansa Tool Integration

If you are new to development for Sciansa see https://github.com/csiro-internal/sciansa-integration for higher level
topics.

This is the most basic beginner tutorial (akin to Hello World!). If you want a more advanced tutorial see the additional
tutorials listed here https://github.com/csiro-internal/sciansa-integration?tab=readme-ov-file#further-reading .

This document is currently in the process of being updated. If needed you can revert to the original version by jumping
to https://github.com/ivcap-works/ivcap-python-ai-tool-template.

**Quick Start:** Jump straight to [Local Development and Testing](#local-development-and-testing).


# Design

Before integrating your tool into Sciansa make sure you consider how your tool will fit into the system architecture.
Ultimately Sciansa is a modular system with each unit having inputs and outputs. How well you define your tools
abstraction and what you choose as the inputs and outputs for your tool module will effect how useful your tool is
within the Sciansa ecosystem. Higher level modular design principles can be found in
[https://github.com/csiro-internal/sciansa-integration](https://github.com/csiro-internal/sciansa-integration).


# Beginners

If you are just starting out it is recommended that you use this repo as a template to guide your development. This repo
is a GitHub template __TODO explain how to use GitHub template.__

This guide targets developers who want to integrate classical tools with well defined inputs and outputs. If you want to
support an agent interaction pattern see the
[Hybrid section in the Sciansa Integration Docs](https://github.com/csiro-internal/sciansa-integration?tab=readme-ov-file#hybrid-advanced).


# Assessing Integration Complexity

The following list will help you to identify how complex it will be to integrate your tool with Sciansa:

**Familiarity with Technologies Used** \
How familiar are you with the technologies listed in the [Technologies](#technologies) section? \
We are still working to understand our developer users better. Please let us know which technologies you are and aren't
familiar with so that we can improve our developer experience.

**Dependencies:** \
How well do you understand your dependencies? Have you tried to put your technology in a Docker container? \
Tools with well understood dependencies or have been containerised before are easier to integrate.

How big are your dependencies? \
This include everything that needs to be packaged to make your tool work (everything beyond the inputs and outputs).

**Dependency Compatibility:** \
Is the tool compatible with the Sciansa dependency set? See: [Technologies](#technologies) \
Identify any significant incompatibilities between the dependencies used by Sciansa and the technologies that you use.

**State:** \
Does the tool maintain an internal state or is it stateless? \
Stateless tools are easier to integrate then tools that require state preservation between calls.

**Resources:** \
What are the compute resources required? \
If your tool requires substantial compute or GPU resources talk with the Sciansa team in the first instance to see if
your compute requirements can be accommodated by the platform.

**Inputs and Outputs:** \
What are the expectations on the Inputs and Outputs for your tool? \
What is the order of magnitude of data required as inputs and outputs for your tool(s) and where are they stored? \
Tools that can accommodate inputs and outputs in standardised formats and that can be written to take these inputs and
outputs as parameters (rather than hard coded files) are easier to integrate.

**Configuration:** \
How is the tool configured? \
Are you able to supply a set of parameters or does the tool have a GUI or interactive workflow? \
Tools that can be configured up front without requiring further interaction are easier to integrate then tools that
need supervisory interactive configuration patterns.

**Extend This List:** \
Thought that your tool would be easy to integrate based on the above list and then found it harder then you expected? \
Please reach out for help and support. \
Also, please make update this list to reflect the additional constraints that made the integration more complex.


# Technologies

These are the technologies that you will need to use to integrate your tool into Sciansa:

The following matrix defines the technologies you will need to use to integrate your tool. If you are starting from
scratch it is recommended that you use the default options. If you are integrating an existing tool the matrix
highlights compatibility.

Type                     | Technology |
-------------------------|------------|
Source Code Management   | Git        |
Language                 | Python     |
Library                  | Pydantic   |
Dependency Management    | Poetry     |
Build System             | Poetry     |
Deployment               | Docker     |
Test Framework           | Make (Todo Replace) |
Infrastructure Framework | IVCAP      |


IVCAP is the backend infrustructure that all Sciansa modules run on. If you have some familiarity with cloud
infurstrucutre, IVCAP is a technology abstraction over the native cloud infrusture.

If you are not familiar with IVCAP the best brief introduction can be found in the IVCAP section of the [Sciansa
Developer Documentation](https://github.com/csiro-internal/sciansa-integration#IVCAP).


# Local Development and Testing

We start by building the template "as is" to verify the development environment and start in a known good working state.
Once you understand how to build, deploy and interact (provide inputs and retrieve outputs - both locally and on the
deployed instance) you can progressively customise the template with your functionality.


## Install Development Dependencies:

After installing the dependencies listed below you should be able to run the commands provided (in the "Test Install"
section) to check the dependencies are installed correctly (versions may differ slightly).

- [Install Git](https://git-scm.com/downloads)
- [Install IVCAP CLI](https://github.com/ivcap-works/gene-onology-term-mapper?tab=readme-ov-file#step-2-install-ivcap-cli-tool-)
  - Make sure you both install the IVCAP CLI and also configure the IVCAP CLI by running `context create` and
  `context login`.
- [Install Poetry and Poetry IVCAP Plugin](https://github.com/ivcap-works/gene-onology-term-mapper?tab=readme-ov-file#step-1-install-poetry-and-ivcap-plugin-)
  - Make sure you install Poetry and also the Poetry IVCAP plugin.
- [Install Docker](https://docs.docker.com/engine/install/)
- Test Install with:
```
$ git version
# Expect: git version 2.43.0

$ poetry --version
# Expect: Poetry (version 2.1.4)

$ poetry ivcap version
# Expect: IVCAP plugin (version 0.5.2)

$ ivcap --version
# Expect: ivcap version 0.41.7|c32cf2b|2025-07-02T00:12:10Z

$ ivcap context get
# Expect:
# +-------------+---------------------------------------------------------+
# | Name        | sd-dev                                                  |
# | URL         | https://develop.ivcap.net                               |
# | Account ID  | urn:ivcap:account:00000000-0000-0000-0000-000000000000  |
# | Provider ID | urn:ivcap:provider:00000000-0000-0000-0000-000000000000 |
# | Authorised  | yes, refreshing after 01 Jan 25 12:34 AEST              |
# +-------------+---------------------------------------------------------+

$ docker --version
# Expect: Docker version 28.1.1+1, build 068a01e

$ docker run hello-world
# Expect:
# Unable to find image 'hello-world:latest' locally
# latest: Pulling from library/hello-world
# 17eec7bbc9d7: Pull complete
# Digest: sha256:a0dfb02aac212703bfcb339d77d47ec32c8706ff250850ecc0e19c8737b18567
# Status: Downloaded newer image for hello-world:latest
#
# Hello from Docker!
# ...
```

> **Note:** You can also see [ivcap-cli](https://github.com/ivcap-works/ivcap-cli) repo for more details about the
IVCAP CLI tool.


## Default Functionality:

The default functionality/operation that this template implements is to check whether a number is prime.

|            | Description |
|------------|-------------|
| **Input**  | Integer     |
| **Output** | Boolean indicating whether the input was prime. |

This default functionality provides a simple and well understood operation that you can test with until you are ready to
replace the logic with your own.


## Build Template:

We start by building the template as is. This packages the code and dependencies into a docker image, that we can
later run.

- Install Template Specific Build Dependencies:
```
$ poetry install --no-root
# Expect:
# Installing dependencies from lock file
#
# Package operations: 74 installs, 0 updates, 0 removals
#
# - Installing ...
```
- Build:
```
$ poetry ivcap docker-build
# Expect:
# INFO: docker buildx build -t ivcap_python_ai_tool_template_x86_64: ...
# ...
# INFO: Docker build completed successfully
```


## Test Build:

Once the docker image has been built we can call the tool that we have packaged; supplying input data and then
inspecting the result.

The following command will start the tool models as a server which listens for incoming requests which supply the input
data:
```
$ poetry ivcap run -- --port 8080
# Expect:
Running: poetry run python tool-service.py --port 8080
2025-05-28T16:24:14+1000 INFO (app): AI tool to check for prime numbers - 0.2.0|b4dbd44|2025-05-28T16:24:13+10:00 - v0.7.2
2025-05-28T16:24:14+1000 INFO (uvicorn.error): Started server process [6311]
2025-05-28T16:24:14+1000 INFO (uvicorn.error): Waiting for application startup.
2025-05-28T16:24:14+1000 INFO (uvicorn.error): Application startup complete.
2025-05-28T16:24:14+1000 INFO (uvicorn.error): Uvicorn running on http://0.0.0.0:8080 (Press CTRL+C to quit)
```

In a separate terminal, call the service via `make test-local` or if you are comfortable you can use your favourite http
testing tool:
_TODO: Replace this step. Remove the need for make as a dependency, replace with Python (since its already a dependency)._
_For now you will also need to make sure that you have `make` installed as a dependency on your system._
```
$ make test-local
# Expect:
# curl -i -X POST \
#     -H "content-type: application/json" \
#     --data @tests/request.json \
#     http://localhost:8080
# HTTP/1.1 200 OK
# date: Tue, 22 Jul 2025 06:32:39 GMT
# server: uvicorn
# job-id: urn:ivcap:job:1f066c5a-a3b4-6f84-a5f7-9eae9cc90b25
# content-length: 67
# content-type: application/json
# ivcap-ai-tool-version: 0.7.15
#
# {"$schema":"urn:sd:schema.is-prime.1","number":997,"is_prime":true}
```

The output from this command shows 3 things:
- Shows the call that was made to the packaged tool (`curl ...`).
- Shows the HTTP response we receive from the packaged tool (`HTTP...`).
- Shows the data in the response we received from the packaged tool (that 997 is prime) (`{"$schema":"urn:sd:schema.is-prime.1","number":997,"is_prime":true}`).

Input and output data are encoded with JSON.

You can also verify the build and view the web service is available by navigating to
[http://localhost:8080/api](http://localhost:8080/api). Here you will find the OpenAPI spec for the endpoints the
service creates if you are familiar with web APIs.

<img src="openapi.png" width="400"/>


# Deployment

Deploying makes the tool available from the Sciansa/IVCAP platform.

It might seem odd to have deployment first. After all why deploy the template? The aim of this tutorial is to start with
something that works and progressively increase the understanding and customisation.

There are 2 options for remote deployment:

| | |
|----------------------------------|-------------------------------------------|
| Automated deployment (Preferred) | - Requirement: All code / models pushed to GitHub repo. </br> - Runs an automated job to build and deploy the container. </br> Advantage: Reproducible |
| Manual deployment                | - Requirement: Developer must understand deployment process. </br> - You manually build and upload your tool. |


## Automated Deployment

- _TODO: To Be Defined. Not yet implemented._


## Manual Deployment

Deployment is a multistep process run from a single command. As the process is a multistep process you must verify that
all of the intermediate steps indicated they completed successfully:
```
$ poetry ivcap deploy
# Expect:
# INFO: docker buildx build ...
# ...
# [+] Building ... FINISHED
# ...
#  Pushing ivcap_python_ai_tool_template_amd64 ...
# ...
# 00000000-0000-0000-0000-000000000000/ivcap_python_ai_tool_template_amd64:0000000 pushed
# INFO: package push completed successfully
# Running: ivcap package list ivcap_python_ai_tool_template_amd64:0000000
# Running: ivcap context get account-id
# Running: poetry run python tool-service.py --print-service-description
# Running: ivcap aspect update --policy urn:ivcap:policy:ivcap.base.metadata urn:ivcap:service:00000000-0000-0000-0000-000000000000 -f /tmp/tmp_n87c8lg
# INFO: service definition successfully uploaded - urn:ivcap:aspect:00000000-0000-0000-0000-000000000000
# Running: poetry run python tool-service.py --print-tool-description
# Running: ivcap context get account-id
# Running: ivcap aspect update --policy urn:ivcap:policy:ivcap.base.metadata urn:ivcap:service:00000000-0000-0000-0000-000000000000 -f /tmp/tmpbw10vbo_
# INFO: tool description successfully uploaded - urn:ivcap:aspect:00000000-0000-0000-0000-000000000000
```


### Test deployed Service

After you have deployed the service you can test the deployment using the following steps.

Run `poetry ivcap job-exec tests/request.json` to execute the service to check if '997' is a prime number:
```
$ poetry ivcap job-exec tests/request.json
# Expect:
# ...
# Creating job 'https://develop.ivcap.net/1/services2/urn:ivcap:service:.../jobs'
# ...
# "result-content": {
#   "$schema": "urn:sd:schema.is-prime.1",
#   "is_prime": true,
#   "number": 997
# },
```

The input data that is supplied to the tool is in `tests/request.json`.

The output from this command shows 3 things:
- A job was created - that is the tool was scheduled to be run (`Creating job...`).
- Shows the data in the response we received from the packaged tool (matches the data from the local run).

> For a more in-depth description of deployment, please refer to
[Step 8: Deploying to IVCAP](https://github.com/ivcap-works/gene-onology-term-mapper?tab=readme-ov-file#step-8-deploying-to-ivcap-)
in the [Gene Ontology (GO) Term Mapper](https://github.com/ivcap-works/gene-onology-term-mapper) tutorial.


# Updating the Template

## Overview

`tool-service.py`: \
**Service:** Defines service details. General information about your tool module. \
**Request:** Input data structure. The general format is key value pairs. Update to take the values that you need to
supply to your tool. This is a Pydantic data structure you can see the Pydantic docs if you need additional features. \
**Result:** Output data structure. Same as `Request`. \
`@ivcap_ai_tool / def is_prime`: Defines the operation you provide. Update to provide your functionality.

`pyproject.toml`: Project details and dependencies.

## Implementation Details

### [tool-service.py](./tool-service.py)

Implements a simple http based service which provides a `POST /` service endpoint to test
if the number contained in the request is a prime number or not.

We first import a few library functions and configure the logging system to use a more "machine" friendly format to
simplify service monitoring on the platform.

```
import math
from pydantic import BaseModel, Field
from pydantic import BaseModel, ConfigDict

from ivcap_service import getLogger, Service
from ivcap_ai_tool import start_tool_server, ToolOptions, ivcap_ai_tool, logging_init

logging_init()
logger = getLogger("app")
```

We then describe the service, who to contact and other useful information used when deploying the service

```
service = Service(
    name="AI tool to check for prime numbers",
    contact={
        "name": "Max Ott",
        "email": "max.ott@data61.csiro.au",
    },
    license={
        "name": "MIT",
        "url": "https://opensource.org/license/MIT",
    },
)
```

The core function of the tool itself is accessible as `POST /`. The service signature should be kept as simple as
possible.
We highly recommend defining the input as well as the result by a single `pydantic` model, respectively.
However, for a tool to be properly used by an Agent, we should provide a
comprehensive function documentation including the required parameters as well as the reply.

Please also note the `@ivcap_ai_tool` decorator. It exposes the service via `POST \`, but also a `GET /`
to allow the platform to obtain the tool description which can be used by agents to select the right
tool but also understand on how to use it.

```
class Request(BaseModel):
    jschema: str = Field("urn:sd:schema:is-prime.request.1", alias="$schema")
    number: int = Field(description="the number to check if prime")

class Result(BaseModel):
    jschema: str = Field("urn:sd:schema:is-prime.1", alias="$schema")
    flag: bool = Field(description="true if number is prime, false otherwise")

@ivcap_ai_tool("/", opts=ToolOptions(tags=["Prime Checker"]))
def is_prime(req: Request) -> Result:
    """
    Checks if a number is a prime number.
    """
    ...
    return Result(flag=True)
```

Finally, we need to start the server
to listen for incoming requests:

```
# Start server
if __name__ == "__main__":
    start_tool_server(service)
```

### [resources.json](./resources.json)

This file contains the resource requirements for this tool. This will depend on the computational and memory
requirements for the specific tool. If it is not provided a default will be used which is likely very similar
to this file.


# Next Steps

Great you have completed the introductory tutorial. You may now want to look at a more advanced tutorial. See either:
- [Advanced tool tutorial](https://github.com/ivcap-works/gene-onology-term-mapper)
- [Example Integrations](https://github.com/csiro-internal/sciansa-integration?tab=readme-ov-file#example-integrations)


# Maintainers Notes

Here are some dot points to help future maintainers of this document and this repo:
- **Intended Audience:**
  - Assumed to have a competent understanding of the tool they plan to integrate.
  - Assumed to be a domain expert with competent level of programming proficiency. The assumption is that the developers
    who want to integrate tools will have a reasonable level of programming proficiency, but will not necessarily be
    professional programmers. They are likely to have deep experience in tools sets and libraries they are familiar with
    but may not have a deep understanding of tools and technologies across a broader development concepts (for example
    they may not have experience with cloud infrastructure, Docker, JSON or web APIs).
  - Assumed have a reasonable familiarity with Python.
