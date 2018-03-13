# elixir-start

elixir-start is an opinionated script and set of templates for creating a new
Elixir project.

## Features

* All development tools are encapsulated in Docker containers
* Support Kubernetes ping, liveness, readiness checks via Phoenix
* Contains modern linters and wobserver
* Supports TDD with high-level UATs to treat project as a black box as well as unit tests in the project

## Installation

### Dependencies

* Docker
* GNU Make
* Bash

### Steps

Currently, installation is crude!

* Pull down the github repo
* Copy the `templates` directory to `$HOME/.elixir-start`
* Copy the `bin/elixir-start` script to a spot that is in your path

## Usage

```
elixir-start $NEW_PROJECT_NAME
```

