# This code grabs a bunch of user information from github

require 'octokit'

usage = "Usage: ruby gir.rb <repo file> <organization> <github username> <github password>"

#setup user login
if ARGV.length >= 4
        puts "logging in"
        client = Octokit::Client.new \
                :login =>ARGV[2],
                :password =>ARGV[3]
        user = client.user
        user.login
elsif ARGV.length >= 2
        puts "No GitHub account specified - using limited requester"
        client = Octokit
else
        abort(usage)
end

puts "using repo file:\t" + ARGV[0]
puts "Scanning organization:\t" + ARGV[1]
org = ARGV[1]

text=File.open(ARGV[0]).read
text.gsub!(/\r\n?/,"\n")
puts "Scraping Issues...\n"
text.each_line do |line|
        puts line
        line.gsub!(/\n/,"")
        output = File.open("#{line}"+".md","w")
        repository = org+"/"+line
        client.auto_paginate = true;
        issues = client.issues(repository)
        issues.each do|issue|
                output << "#"
                output << issue.title
                
                output << "\n**Author:** " << issue.user.login
                output << "\n**Assignee:** "
                if issue.assignee 
                    output << issue.assignee.login
                end

                output << "\n**Labels:** "
                issue.labels.each do |label|
                    output << label.name << " "
                end
                output << "\n" << issue.body.gsub!(/\r\n?/,"\n") << "\n------\n"
                
                sleep(1);

        end
        output.close
end     
        

#get File Commits
#filename
#sha
#additions
#deletions
