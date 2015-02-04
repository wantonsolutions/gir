require 'optparse'
require 'octokit'

def getClient(options)
    if options[:user] != "" and options[:pass] != "" 
        if options[:verbose]
            puts "user = " + options[:user]
            puts "pass = " + options[:pass]
        end
        return Octokit::Client.new \
            :login => options[:user],
            :password => options[:pass]
    else
        puts "No GitHub account specified - using limited requester"
        return Octokit
    end
end

def parseOptions
    options = {}
    optparse = OptionParser.new do|opts|
        opts.banner = "Usage: ruby gir.rb <repo list files>"
    
        options[:markdown] = false
        opts.on('-m', '--markdown', 'Use markdown syntax for output') do
            options[:markdown] = true
        end
    
        options[:user] = ""
        opts.on('-u', '--username GITHUB_LOGIN', 'GitHub login name') do|name|
            options[:user] = name
        end
    
        options[:pass] = ""
        opts.on('-p', '--password GITHUB_PASSWORD', 'GitHub password') do|pass|
            options[:pass] = pass
        end
    
        options[:mess] = false
        opts.on('-s', '--short-path', 'Store output files in same directory instead of <Owner>/<Repo>') do
            options[:mess] = true
        end
    
        opts.on('-h', '--help', 'Display this screen') do
            puts opts
            exit
        end
    
        options[:verbose] = false
        opts.on('-v', '--verbose', 'Use verbose output') do
            options[:verbose] = true
        end
    end
    
    optparse.parse!

    if options[:markdown]
        @headings = {
            :author => "**Author:**",
            :assignee => "**Assignee:**",
            :labels => "**Labels:**" }
    else
        @headings = {
            :author => "Author:",
            :assignee => "Assignee:",
            :labels => "Labels:" }
    end

    return options
end

def scrapeIssues(options, client, repo, path)
    puts "Scraping Issues from " + repo + "... "
    if options[:mess]
        output = File.open("#{path[1]}"+".md","w")
    else
        FileUtils.mkdir_p path[0]
        output = File.open("#{repo}"+".md","w")
    end
    client.auto_paginate = true;
    issueLabels = {}
    issues = client.issues(repo)
    issues.each do|issue|
        if issue.labels.size > 0
            name = issue.labels.each.peek.name
        else
            name = ""
        end
        if not issueLabels.include? name
            issueLabels[name] = []
        end
        issueLabels[name].push(issue)
    end

    issueLabels.each do|epic|
        epicName = epic[0]
        if options[:markdown]
            output << "#"
        end
        output << epicName << "    \n"

        issueLabels[epicName].each do|issue|
            if options[:markdown]
                output << "##"
            end
            output << issue.title << "  \n" \
                << @headings[:author] << " " << issue.user.login << "  \n" \
               << @headings[:assignee] << " "
            if issue.assignee 
                output << issue.assignee.login
            end
    
            output << "  \n" << @headings[:labels]
            first = true
            issue.labels.each do |label|
                if not first
                    output << ","
                else
                    first = false
                end
                output << " " << label.name
            end
            output << "  \n" << issue.body.gsub!(/\r\n?/,"  \n") << "  \n\n"
        end
        output << "\n------\n"
    end
    output.close
    if options[:markdown]
        system("perl ./Markdown.pl " + File.path(output) + " > " +
               File.path(output).gsub(/\.md$/,".html"))
    end
end
