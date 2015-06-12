DOCKER = docker
REPO = git@github.com:aptible/docker-mysql.git
TAGS = 5.6.25

all: release

sync-branches:
	git fetch $(REPO) master
	@$(foreach tag, $(TAGS), git branch -f $(tag) FETCH_HEAD;)
	@$(foreach tag, $(TAGS), git push $(REPO) $(tag);)
	@$(foreach tag, $(TAGS), git branch -D $(tag);)

release: $(TAGS)
	$(DOCKER) push quay.io/aptible/mysql

build: $(TAGS)

.PHONY: $(TAGS)
$(TAGS):
	$(DOCKER) build -t quay.io/aptible/mysql:$@ $@
