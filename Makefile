SHELL := /bin/bash

.PHONY: configure manager test report

configure:
	perl bin/configure.pl

manager:
	hypnotoad bin/server/manage.pl

test:
	prove t

cover:
	HARNESS_PERL_SWITCHES=-MDevel::Cover prove t
	cover -report html_basic
