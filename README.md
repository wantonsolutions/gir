#gir
Github Issue Ripper

Objective
---------
Rip all the issues from a set of repositories into individual files

Dependencies
------------
gir makes use of :
<ul>
<li>Ruby 2.1.5 although eariler versions will most certianly work</li>
<li>Octokit.rb (a ruby gem for parsing github repositories</li>
</ul>

Usage
-----
With the dependencies correctly installed gir can be run with the following commands
ruby gir.rb <repolist.txt> <organization> <github username> <github password>

where repolist.txt is a file containing one repository per line, and organization can refer to either an organization or a user.

ex) if you wanted to get the issues from Linus Torvals repolist.txt would be formatted as follows

repolist.txt
------------
linux
subsurface
------------

gir.rb would be called as follows

ruby gir repolist.txt torvalds username password
