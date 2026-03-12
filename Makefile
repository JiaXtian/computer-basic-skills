.PHONY: serve build lint linkcheck

serve:
	mkdocs serve

build:
	mkdocs build --strict

lint:
	markdownlint-cli2 "**/*.md"

linkcheck:
	lychee README.md docs/**/*.md --no-progress
