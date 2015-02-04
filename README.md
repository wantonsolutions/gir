#gir
Github Issue Ripper

Objective
---------
Rip all the issues from a set of repositories into individual files

Dependencies
------------
gir makes use of :
- Ruby 2.1.5 although eariler versions will most certianly work  
- Octokit.rb (a ruby gem for parsing github repositories)  
- prawn (for PDF output)  

Usage
-----
With the dependencies correctly installed gir can be run with the following commands:
For public repos:  
`ruby gir.rb <repolist.txt>`  
For private repos:  
`ruby gir.rb <repolist.txt> -uUSERNAME -pPASSWORD`  

where repolist.txt is a file containing one repository per line, and organization can refer to either an organization or a user.

For example, if you wanted to get the issues from Linus Torvals repolist.txt would be formatted as follows

*repolist.txt*
```
torvalds/linux
torvalds/subsurface
```

... and gir would be run by `ruby gir repolist.txt`
