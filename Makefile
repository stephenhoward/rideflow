SHELL := /bin/bash

.PHONY: configure manager test report

configure:
	perl bin/configure.pl

manage:
	hypnotoad bin/server/manage.pl

test:
	prove -r t

cover:
	cover -delete
	HARNESS_PERL_SWITCHES=-MDevel::Cover prove -r t
	cover -report html_basic
