.PHONY: naive cachedeps cacheobjs cacheobjs-base tailybuild tailybuild-base profile clean

define inject-nonce
  sed -i -e 's/nonce = .*$$/nonce = "$(shell date)"/' cmd/example/main.go
endef

define reset-nonce
  sed -i -e 's/nonce = .*$$/nonce = "Friday"/' cmd/example/main.go
endef

profile:
	python3 profile.py

naked:
	$(call inject-nonce)
	go run ./cmd/example/main.go

naive:
	$(call inject-nonce)
	docker build -t windmill.build/buildbench/naive -f Dockerfile.naive .
	docker run --rm -it windmill.build/buildbench/naive

cachedeps:
	$(call inject-nonce)
	docker build -t windmill.build/buildbench/cachedeps -f Dockerfile.cachedeps .
	docker run --rm -it windmill.build/buildbench/cachedeps

cacheobjs-base:
	if [ "$(shell docker images windmill.build/buildbench/cacheobjs-base -q)" = "" ]; then \
		docker build -t windmill.build/buildbench/cacheobjs-base -f Dockerfile.cacheobjs --target=obj-cache .; \
	fi;

cacheobjs: cacheobjs-base
	$(call inject-nonce)
	docker build --build-arg baseImage=windmill.build/buildbench/cacheobjs-base \
               -t windmill.build/buildbench/cacheobjs \
               -f Dockerfile.cacheobjs .
	docker run --rm -it windmill.build/buildbench/cacheobjs

tailybuild-base:
	if [ "$(shell docker ps --filter=name=tailybuild -q)" = "" ]; then \
		docker build -t windmill.build/buildbench/tailybuild-base -f Dockerfile.tailybuild .; \
    docker run --name tailybuild -d windmill.build/buildbench/tailybuild-base; \
	fi;

tailybuild: tailybuild-base
	$(call inject-nonce)
	docker exec -it tailybuild rm -fR cmd
	docker cp cmd tailybuild:/go/src/github.com/windmilleng/buildbench/ 
	docker exec -it tailybuild go install github.com/windmilleng/buildbench/cmd/example
	docker exec -it tailybuild /go/bin/example

tailymount-base:
	if [ "$(shell docker ps --filter=name=tailymount -q)" = "" ]; then \
		docker build -t windmill.build/buildbench/tailymount-base -f Dockerfile.tailymount .; \
    docker run --mount type=bind,source=$(shell pwd)/cmd,target=/go/src/github.com/windmilleng/buildbench/cmd \
           --name tailymount -d windmill.build/buildbench/tailymount-base; \
	fi;

tailymount: tailymount-base
	$(call inject-nonce)
	docker exec -it tailymount go install github.com/windmilleng/buildbench/cmd/example
	docker exec -it tailymount /go/bin/example

clean:
	$(call reset-nonce)
	docker kill tailybuild && docker rm tailybuild || exit 0
	docker kill tailymount && docker rm tailymount || exit 0
	docker rmi -f $(shell docker image ls --filter=reference=windmill.build/buildbench/* -q) || exit 0
