# RideFlow

This project aims to be a complete software solution for small and medium transit systems.  It will include apis for a servers managing routes and fares, and client applications to use for vending machines, vehicle pay terminals, mobile apps, etc.

Which open source license this project will be under is still under consideration.

## Primary System Goals

* **Accessible to Low Income Riders:** Riders should not have to have a smartphone or bank account to purchase rides on the system.
* **Attractive to Affluent Riders:** Riders that have them should be able to pay with smartphones, smartwatches or other personal technology.
* **Low Employee Count:** The system should not require a large staff to operate.
* **Rider Anonymity:** riders should not need an account with the transit agency to use most system features.
* **Multilingual Ridership** rider information and UI should be accessible in multiple languages.
* **Accessible to the Impaired** rider information and UI should be accessible to those with physical and mental impairments.

## Secondary System Goals

*  **Autonomous-Vehicle Ready:** The system should be designed to allow for both driver-controlled and driverless vehicles.

## Installing and Running

This early in the project's lifecycle it runs inside a virtual environment, namely VirtualBox. It uses Vagrant and Ansible to set up the machine

    > cd vagrant/server
    > vagrant up

Once the machine is built and provisioned, there are a couple of steps to finish.

First, you will probably want to download the rideflow-manager project, so you can use a web interface with the server.  It has an ansible playbook that can be applied to the same VM.

Then, this handful of shell commands will get things off the ground:

    > vagrant ssh
    > sudo service nginx restart # nginx is not yet starting on boot (TODO)
    > sudo su - dev              # switch to the dev user
    > cd /rideflow
    > perl bin/configure.pl
    > psql -U rideflow -f db/schema.sql rideflow  # install the database schema built in the last step
    > perl bin/add_user.pl                        # create a user so you can log in to the service
    > hypnotoad bin/server/manage.pl              # start the service