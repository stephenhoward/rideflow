SHELL := /bin/bash

.PHONY: configure manager test report

configure:
	- cwd /rideflow
	perl bin/configure.pl

manager:
	- cwd /rideflow
	hypnotoad bin/server/manage.pl

test:
	- cwd /rideflow
	prove t

cover:
	- cwd /rideflow
	HARNESS_PERL_SWITCHES=-MDevel::Cover prove t
	cover -report html_basic
