# NodeJS in a box

Debian (Jessie) base Docker image with NodeJS 7.4.0+.
The difference from the main distribution image is the this one is built from scratch,
so it has full intl support.

Number.prototype.toLocaleString() and Date.prototype.toLocaleString() work as expected.

[![](https://badge.imagelayers.io/redss/node:latest.svg)](https://imagelayers.io/?images=redss/node:latest)

[![Build Status](https://travis-ci.org/redss/node.svg)](https://travis-ci.org/redss/node)

## Usage

The scope of this image is intended both for development and production.

- When using in production create you own image deriving from this (Actually volume `/app` is set as workdir).

    For example, in the case your node application could use Expressjs listening on port 8080, your docker file could be:

        # Dockerfile
            FROM redss/nodejs:7.4.0
            EXPOSE 8080

- In development mode things are a bit more interesting.

    While your application will be mounted on volume '/app' you need that the current
    image user will have the same `uid` of the user working on the hosting machine (you!).

    You could create a Dockerfile setting your UID, but this could not be right
    for other members in your team.
    To solve this issue one easy solution is to create a script the sets the image
    UID dinamically.

    On a Linux (or Mac) hosting system the script could be something like

        #!/bin/sh
        ### initialize.sh ###
        docker run -t --name=tempname redss/node:7.4.0 useradd -u $UID node && \
        docker commit tempname $USER/applicationName:latest
        docker rm tempname

    After creating the image you usually need a script to work on a docker instance
    excluding the nodejs installation on your hosting machine (yes, you could not have
    nodejs installed at all).

    This script could be used (again just for Linux and Mac users):

        #!/bin/sh
        ### remote.sh ###
        docker run --rm -ti -u $(id -u):$(id -g)  -v $(pwd):/data -v ${OUT:-/tmp}:/out $USER/applicationName:latest $@

    To install npm dependencies then you could do `./remote.sh npm install`.

    Scripts on package.json could similarly be like the following:

        {
            ...
            "scripts": {
                "initialize": "sh ./initialize.sh",
                "app": "sh ./remote.sh node .",
                "rinstall": "sh ./remote.sh npm install",
                "rbuild": "sh ./remote.sh ./node_modules/.bin/babel src -d lib --source-maps",
                "rtest": "sh ./remote.sh ./node_modules/.bin/mocha --compilers js:babel-core/register src/test"
            }
        }
