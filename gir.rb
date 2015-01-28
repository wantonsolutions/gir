# This code grabs a bunch of user information from github

require 'octokit'

usage = "Usage: \truby gir.rb <repo.txt> <organization> <github username> <github password>\nex)\truby gir.rb repo.txt UBC username password\n\n"

#setup user login
if ARGV.length == 4
	puts "logging in"
	client = Octokit::Client.new \
		:login =>ARGV[2],
		:password =>ARGV[3]
	user = client.user
	user.login
else
	puts "Insufficiant login info using limited requester"
	puts usage
	client = Octokit
end
#determine repo
if ARGV.length < 4
	die (usage)
else
	puts "using repo file:\t" + ARGV[0]
	puts "Scanning organization:\t" + ARGV[1]
	org = ARGV[1]
end

text=File.open(ARGV[0]).read
text.gsub!(/\r\n?/,"\n")
text.each_line do |line|

	output = File.open("#{line}","w")
	repository = org+line

	client.auto_paginate = true;
	issues = client.issues repository
	issues.each do|issue|
		output << ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
		output << "Title:\t"
		output << issue.title
		output << "\n"
		
		output << "Author:\t"
		output << issue.user.login
		output << "\n"
		if issue.assignee 
			output << "Assignee:\t"
			output << issue.assignee.login
			output << "\n"
		end

		issue.labels.each do |label|
			output << "Lable:\t"
			output << label.name
			output << "\n"
		end
		output << "Body:\n"
		output << issue.body
		output << "\n"
		output << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n"
		
		sleep(1);

	end
	output.close
end	
	

#get File Commits
#filename
#sha
#additions
#deletions
