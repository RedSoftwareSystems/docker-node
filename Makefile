NAME = node
VERSION = 0.0.1
REGISTRY = redss

.PHONY: all build tag_latest release

default: tag_latest

build:
	docker build --rm -t $(REGISTRY)/$(NAME):$(VERSION) image

tag_latest: build
	docker tag $(REGISTRY)/$(NAME):$(VERSION) $(REGISTRY)/$(NAME):latest

release: tag_latest
	docker push $(REGISTRY)/$(NAME):$(VERSION)
	docker push $(REGISTRY)/$(NAME):latest
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"
