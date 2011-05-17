# Installation script for Storytlr

This project automates the installation of Storytlr on a virtual
machine. I've written it to allow me to develop plugins and themes
without modifying the setup on my local machine.

This uses [VirtualBox](http://www.virtualbox.org/) and
[Vagrant](http://vagrantup.com/) to manage virtual machines, and I
have written a provisioning install shell script.

The install shell script is not limited to virtual machines - there is
no reason why you couldn't use the shell script on a 'real'
machine. However it would probably require some modifications.

You can specify various options in the install script, including
whether storytlr is downloaded from the Git repository, or the
official release. 

By default the user is called 'admin' and the passwords are
'123456'. It's a very good idea to change these if you're doing
anything other than development.

Once Vagrant and VirtualBox are installed you can start the virtual
machine by using the `vagrant up` command. Once the virtual machine is
up and running you'll need to add the following line to your /etc/hosts file:

    33.33.33.10  vagrant admin.vagrant

`admin` is the default username - for any new users you'll need to
append them to this line in the form `<username>.vagrant`.

_Owen Griffin - May 2011_
