Executer
===========

A daemon that executes commands given to it. 

Requirements
------------

* redis
* executer gem: gem install executer

Setup
------------

You'll need to set up the executer.yml to point to the redis server executer will use.  Example:

<pre>
$ cat config/executer.yml
redis: localhost:6379
</pre>

To start the daemon:

<pre>
executer config/executer.yml

Starting executer server (redis @ localhost:6379)...

</pre>

To use the client and push commands to the daemon:

<pre>
$ irb
> require 'executer'
> Executer::Client.new('localhost:6379').run :cmd => 'uname >> /tmp/uname.txt', :id => 1
</pre>

To verify that the command got executed:

<pre>
$ cat /tmp/uname.txt 
Darwin
</pre>