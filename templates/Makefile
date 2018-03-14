ELIXIR_IMAGE={{ELIXIR_IMAGE}}
ELIXIR_PROJECT_NAME={{ELIXIR_PROJECT_NAME}}
MSSQL_PASSWORD='{{MSSQL_PASSWORD}}'

.PHONY: all check clean format repl repl-mix

all: check

check: control/uats control/mix-format-check control/credo-check control/dialyzer-check
	@echo "All checks complete"

clean:
	git clean -ffxd

repl: control/elixir-image
	docker run -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it ${ELIXIR_IMAGE} iex

repl-mix: control/mix-deps control/mssql-container control/elixir-image
	docker run --network ${ELIXIR_PROJECT_NAME}-uats -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it -p 4000:4000 -p 4001:4001 ${ELIXIR_IMAGE} iex -S mix phx.server

format: control/elixir-image
	docker run -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it ${ELIXIR_IMAGE} mix format --check-equivalent mix.exs "lib/**/*.{ex,exs}" "test/**/*.{ex,exs}"

# https://hub.docker.com/r/microsoft/mssql-server-linux/
control/mssql-container: control/control control/uats-network control/mssql-image uats/mssql-image/build-mssql.sh
	uats/mssql-image/build-mssql.sh ${MSSQL_PASSWORD}
	touch "$@"

control/mssql-image: uats/mssql-image/Dockerfile
	docker build -t ${ELIXIR_PROJECT_NAME}-mssql -f uats/mssql-image/Dockerfile .
	touch "$@"

control/uats-network:
	-docker rm -f ${ELIXIR_PROJECT_NAME}-mssql
	-docker network rm ${ELIXIR_PROJECT_NAME}-uats
	docker network create ${ELIXIR_PROJECT_NAME}-uats
	touch "$@"

control/uats: control/control control/elixir-unit control/uats-deps control/mssql-container control/project-image $(wildcard uats/test/*) $(wildcard uats/**/*)
	docker run --network ${ELIXIR_PROJECT_NAME}-uats -v /usr/bin/docker:/usr/bin/docker:ro -v /var/run/docker.sock:/var/run/docker.sock:rw -v "${PWD}/control/mix":/root/.mix -v "${PWD}/uats":/work -w /work --rm -it ${ELIXIR_IMAGE} mix test
	touch "$@"

control/uats-deps: uats/mix.exs
	docker run -v "${PWD}/control/mix":/root/.mix -v "${PWD}/uats":/work -w /work --rm -it ${ELIXIR_IMAGE} mix deps.get
	touch "$@"

control/project-image: control/control control/elixir-image uats/project-image/Dockerfile
	docker build -t ${ELIXIR_PROJECT_NAME}-project -f uats/project-image/Dockerfile .
	touch "$@"

uats/project-image/Dockerfile: foo_bar/_build/prod/rel/foo_bar/bin/foo_bar
	touch "$@"

foo_bar/_build/prod/rel/foo_bar/bin/foo_bar: ${ELIXIR_PROJECT_NAME}/rel/config.exs \
                                             ${ELIXIR_PROJECT_NAME}/config/prod.exs \
                                             ${ELIXIR_PROJECT_NAME}/config/prod.secret.exs \
                                             control/mix-deps \
                                             $(wildcard ${ELIXIR_PROJECT_NAME}/lib/*) $(wildcard ${ELIXIR_PROJECT_NAME}/lib/**/*) \
                                             $(wildcard ${ELIXIR_PROJECT_NAME}/src/*) $(wildcard ${ELIXIR_PROJECT_NAME}/src/**/*) \
                                             $(wildcard ${ELIXIR_PROJECT_NAME}/test/*) $(wildcard ${ELIXIR_PROJECT_NAME}/test/**/*)
	docker run -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}/assets":/work -w /work --rm -it ${ELIXIR_IMAGE} node_modules/brunch/bin/brunch b -p
	docker run -e MIX_ENV=prod -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it ${ELIXIR_IMAGE} mix phx.digest
	docker run -e MIX_ENV=prod -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it ${ELIXIR_IMAGE} mix release --verbose

${ELIXIR_PROJECT_NAME}/rel/config.exs: control/elixir-image
	docker run -e MIX_ENV=prod -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm ${ELIXIR_IMAGE} mix release.init

control/mix-format-check: control/control \
                          control/elixir-image \
                          control/mix-deps \
                          $(wildcard ${ELIXIR_PROJECT_NAME}/lib/*) $(wildcard ${ELIXIR_PROJECT_NAME}/lib/**/*) \
                          $(wildcard ${ELIXIR_PROJECT_NAME}/src/*) $(wildcard ${ELIXIR_PROJECT_NAME}/src/**/*) \
                          $(wildcard ${ELIXIR_PROJECT_NAME}/test/*) $(wildcard ${ELIXIR_PROJECT_NAME}/test/**/*)
	docker run -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it ${ELIXIR_IMAGE} mix format --check-formatted mix.exs "lib/**/*.{ex,exs}" "test/**/*.{ex,exs}"
	touch "$@"

control/credo-check: control/control \
                     control/elixir-image \
                     control/mix-deps \
                     $(wildcard ${ELIXIR_PROJECT_NAME}/lib/*) $(wildcard ${ELIXIR_PROJECT_NAME}/lib/**/*) \
                     $(wildcard ${ELIXIR_PROJECT_NAME}/src/*) $(wildcard ${ELIXIR_PROJECT_NAME}/src/**/*) \
                     $(wildcard ${ELIXIR_PROJECT_NAME}/test/*) $(wildcard ${ELIXIR_PROJECT_NAME}/test/**/*)
	docker run -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it ${ELIXIR_IMAGE} mix credo
	sudo chown -R $(shell whoami):$(shell whoami) "${PWD}"
	touch "$@"

control/dialyzer-check: control/control \
                        control/elixir-image \
                        control/mix-deps \
                        $(wildcard ${ELIXIR_PROJECT_NAME}/lib/*) $(wildcard ${ELIXIR_PROJECT_NAME}/lib/**/*) \
                        $(wildcard ${ELIXIR_PROJECT_NAME}/src/*) $(wildcard ${ELIXIR_PROJECT_NAME}/src/**/*) \
                        $(wildcard ${ELIXIR_PROJECT_NAME}/test/*) $(wildcard ${ELIXIR_PROJECT_NAME}/test/**/*)
	docker run -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it ${ELIXIR_IMAGE} mix dialyzer
	sudo chown -R $(shell whoami):$(shell whoami) "${PWD}"
	touch "$@"

control/elixir-unit: control/control \
                     control/elixir-image \
                     control/mix-deps \
                     $(wildcard ${ELIXIR_PROJECT_NAME}/lib/*) $(wildcard ${ELIXIR_PROJECT_NAME}/lib/**/*) \
                     $(wildcard ${ELIXIR_PROJECT_NAME}/src/*) $(wildcard ${ELIXIR_PROJECT_NAME}/src/**/*) \
                     $(wildcard ${ELIXIR_PROJECT_NAME}/test/*) $(wildcard ${ELIXIR_PROJECT_NAME}/test/**/*)
	docker run -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it ${ELIXIR_IMAGE} mix test
	touch "$@"

control/mix-deps: control/control control/elixir-image control/hex control/rebar ${ELIXIR_PROJECT_NAME}/mix.exs
	docker run -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it ${ELIXIR_IMAGE} mix deps.get
	sudo chown -R $(shell whoami):$(shell whoami) "${PWD}"
	touch "$@"

control/hex: control/control control/elixir-image
	docker run -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it ${ELIXIR_IMAGE} mix local.hex --force
	sudo chown -R $(shell whoami):$(shell whoami) "${PWD}"
	touch "$@"

control/rebar: control/control control/elixir-image
	docker run -v "${PWD}/control/mix":/root/.mix -v "${PWD}/${ELIXIR_PROJECT_NAME}":/work -w /work --rm -it ${ELIXIR_IMAGE} mix local.rebar --force
	sudo chown -R $(shell whoami):$(shell whoami) "${PWD}"
	touch "$@"

control/elixir-image: elixir/Dockerfile
	docker build -t ${ELIXIR_IMAGE} elixir/
	touch "$@"

control/control:
	mkdir -p control
	touch "$@"

