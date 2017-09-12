# CATPHISH
Generate similar-looking domains for phishing attacks. Check expired domains and their categorized domain status to evade proxy categorisation. Whitelisted domains are perfect for your C2 servers. Perfect for Red Team engagements. 

# Installation
```
bundle install
```

# Current Algorithms
* SingularOrPluralise
* prependOrAppend
* doubleExtensions
* mirrorization
* homoglyphs
* dashOmission
* Punycode

Version 1.1.0:
```
The parser for command line options is modified to compensate with the new expired feature. This new option structure gives the tool a new look and more organized.
```

# Usage
Running the tool:
```
catphish.rb [global options] COMMAND [command options]
```
Options:
```
  generate                    Generate domains
  expired                     Find available expired domains
(experimental)

Additional help
  catphish.rb COMMAND -h

Options
  -l, --logo, --no-logo                      ASCII art banner
                                             (default: true)
  -c, --column-header, --no-column-header    Header for each column
                                             of the output (default:
                                             true)
  -D, --Domain=<s>                           Target domain to analyze
  -V, --Verbose                              Show all domains,
                                             including non-available
                                             ones
  -h, --help                                 Show this message
```
Example:
```
catphish.rb -D DOMAIN generate -A
```

## Docker

You can also run the tool with Docker! This lets you try it out without any of the required dependencies (ruby), except
Docker itself. This presumes that you have the docker daemon installed. If not, see
[Docker's documentation](https://docs.docker.com/engine/installation/).

First, build the container

```
$ cd path/to/repository

# Generate a tag so we know how to find the container later to run it. You can use anything (latest is common);
# here the git hash is used.
$ TAG=$(git rev-parse --short HEAD)

# Run the build
$ docker build --tag "catphish:${TAG}" .

# Eventually docker will print something like:
#
#   Successfully built 8f0b8bfe0c41
#   Successfully tagged catphish:f947517

```

Perfect! Now, you can execute catphish via Docker:

```
$ docker run \
    --rm=true \
    "catphish:${TAG}" \
        --Domain ring0labs.com \
        --All
```

# In Action

![alt tag](https://github.com/ring0lab/catphish/blob/master/image1.png)

# COPYRIGHT
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
