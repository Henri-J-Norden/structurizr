TAG ?= structurizr/lite:latest
DATA_DIR ?= ./data

.PHONY: all sync-ui build-war build-image recreate clean

all: build-image recreate

sync-ui:
	cd structurizr-lite && sh ui.sh

build-war: sync-ui
	docker buildx build --target artifact --output type=local,dest=dist .
	mkdir -p structurizr-lite/build/libs/
	mv dist/artifacts/structurizr-lite.war structurizr-lite/build/libs/structurizr-lite.war

build-image: build-war
	docker build -f structurizr-lite/Dockerfile structurizr-lite/ -t $(TAG) --load

recreate:
	@CONTAINERS=$$(docker ps --filter "ancestor=$(TAG)" --format '{{.ID}}' 2>/dev/null); \
	if [ -z "$$CONTAINERS" ]; then \
		echo "No existing containers using $(TAG). Nothing to recreate."; \
	else \
		for cid in $$CONTAINERS; do \
			echo "Recreating container $$cid ..."; \
			NAME=$$(docker inspect --format '{{.Name}}' $$cid | sed 's|^/||'); \
			RUN_ARGS="-d --name $$NAME"; \
			PORTS=$$(docker inspect --format '{{range $$p,$$conf := .NetworkSettings.Ports}}{{range $$conf}}-p {{.HostPort}}:{{index (split $$p "/") 0}} {{end}}{{end}}' $$cid); \
			RUN_ARGS="$$RUN_ARGS $$PORTS"; \
			VOLS=$$(docker inspect --format '{{range .Mounts}}-v {{.Source}}:{{.Destination}} {{end}}' $$cid); \
			RUN_ARGS="$$RUN_ARGS $$VOLS"; \
			ENVS=$$(docker inspect --format '{{range .Config.Env}}-e {{.}} {{end}}' $$cid); \
			RUN_ARGS="$$RUN_ARGS $$ENVS"; \
			LABELS=$$(docker inspect --format '{{range $$k,$$v := .Config.Labels}}--label {{$$k}}={{$$v}} {{end}}' $$cid); \
			RUN_ARGS="$$RUN_ARGS $$LABELS"; \
			RESTART=$$(docker inspect --format '{{.HostConfig.RestartPolicy.Name}}' $$cid); \
			[ "$$RESTART" != "no" ] && RUN_ARGS="$$RUN_ARGS --restart $$RESTART"; \
			NETWORKS=$$(docker inspect --format '{{range $$net,$$conf := .NetworkSettings.Networks}}--network {{$$net}} {{end}}' $$cid); \
			RUN_ARGS="$$RUN_ARGS $$NETWORKS"; \
			echo "  Stopping and removing old container..."; \
			docker rm -f $$cid; \
			echo "  Starting new container..."; \
			docker run $$RUN_ARGS $(TAG); \
		done; \
	fi

clean:
	rm -rf dist/artifacts
