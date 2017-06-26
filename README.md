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

# Usage
Running the tool:
```
ruby catphish.rb -D DOMAIN [options]
```
Options:
```
  -l, --logo, --no-logo                      ASCII art banner (default: true)
  -c, --column-header, --no-column-header    Header for each column of the output (default: true)
  -D, --Domain=<s>                           Target domain to analyze
  -t, --type=<s>                             Type of level domains: (popular, country, generic) (default:
                                             popular)
  -V, --Verbose                              Show all domains, including non-available ones
  -A, --All                                  Use all of the possible methods
  -M, --Mirrorization                        Use the mirrorization method.
  -s, --singular-or-pluralise                Use the singular or pluralise method.
  -p, --prepend-or-append                    Use the prepend or append method.
  -T, --Top-level-domains=<s+>               Use a specific ( set of ) top-level domain(s).
  -H, --Homoglyphs                           Use the homoglyphs method.
  -d, --double-extensions                    Use the double extensions method
  -a, --Dash-omission                        Use the dash omission method.
  -P, --Punycode                             Use the punycode method.
  -h, --help                                 Show this message
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
