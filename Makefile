.PHONY: build clean help default deploy setup-gh-pages

default: build

NOTEBOOKS := explore.ipynb model.ipynb
NOTEBOOKS_HTML := $(patsubst %.ipynb, docs/%.html, $(NOTEBOOKS))

PYTHON_SCRIPTS := acquire.py prepare.py make_predictions.py
PYTHON_SCRIPTS_HTML := $(patsubst %.py, docs/%.html, $(PYTHON_SCRIPTS))

MD_FILES := index.md
MD_HTML := $(patsubst %.md, docs/%.html, $(MD_FILES))

ALL_HTML := $(NOTEBOOKS_HTML) $(PYTHON_SCRIPTS_HTML) $(MD_HTML)

docs/%.html: %.ipynb
	@mkdir -p $(dir $@)
	jupyter nbconvert $<
	mv $(basename $<).html $@

docs/%.html: %.py
	@mkdir -p $(dir $@)
	pycco $<

docs/%.html: %.md
	@mkdir -p $(dir $@)
	/usr/local/bin/pandoc --template github $< > $@

build: $(ALL_HTML) ## build html from the source files into the docs directory

deploy: build ## Build the html, then add, commit changes, and push to the gh-pages branch
	cd docs &&\
		git init &&\
		git add -A &&\
		git commit -m 'Deploy $(shell date)' &&\
		git remote add origin $(shell git remote get-url origin) &&\
		git push origin master:gh-pages -f &&\
		rm -rf .git

clean: ## Clean up built files
	rm -rf docs/*

help: ## Show this help message
	@grep -E '^[a-zA-Z._-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[34m%s\033[0m\t%s\n", $$1, $$2}' | column -ts$$'\t'
