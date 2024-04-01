# Makefile

.PHONY: generate
generate:
	TUIST_ROOT_DIR=${PWD} tuist generate

.PHONY: install
install:
	tuist clean
	tuist install
	TUIST_ROOT_DIR=${PWD} tuist generate

.PHONY: reset
reset:
	tuist clean
	rm -rf **/*.xcodeproj
	rm -rf *.xcworkspace

.PHONY: gitClean
gitClean:
	git branch --merged | grep -v "\*" | xargs -I % git branch -d %
	git fetch --prune
