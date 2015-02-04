# This code grabs a bunch of user information from github

require 'octokit'
require 'fileutils'
require './gir_helper.rb'

options = parseOptions

if options[:verbose] and options[:markdown]
    puts "Using markdown for output"
end

client = getClient(options)
user = client.user
user.login

if options[:verbose]
    if ARGV.size > 0
        puts "Scanning repos from: " + ARGV*", " + "\n\n"
    else
        puts "Scanning repo names from console - type a blank line to end"
    end
end

ARGF.each_line do |repo|
    repo.gsub!(/[\r\n]/,"")
    if not client.repository? repo
        if repo != ""
            puts "Repo '" + repo + "' doesn't exist"
            next
        else
            exit
        end
    end
    scrapeIssues(options, client, repo)
end     
        

#get File Commits
#filename
#sha
#additions
#deletions
