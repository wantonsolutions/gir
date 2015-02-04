require 'optparse'
require 'octokit'
require 'prawn'

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

        options[:pdf] = false
        opts.on('-P', '--pdf', 'Generate PDF output files') do
            options[:pdf] = true
        end
    
        options[:html] = false
        opts.on('-H', '--html', 'Generate HTML output files') do
            options[:html] = true
        end
         
        options[:text] = false
        opts.on('-T', '--text', 'Generate plaintext output files') do
            options[:text] = true
        end
         options[:markdown] = false
        opts.on('-M', '--markdown', 'Generate markdown-formatted output files') do
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
    return options
end

def outputPdf(options, issueLabels, repo)
    output = Prawn::Document.new
    issueLabels.each do|epic|
        epicName = epic[0]
        output.text "<font size='20'><b><u>#{epicName}</u></b></font>",
            :inline_format =>true

        issueLabels[epicName].each do|issue|
            output.text "<font size='16'><b>#{issue.title}</b></font>\n",
                :inline_format =>true

            output.text "<b>Author:</b> #{issue.user.login}",
                :inline_format =>true

            if issue.assignee 
                output.text "<b>Assignee:</b> #{issue.assignee.login}",
                :inline_format =>true
            else
                output.text "<b>Assignee:</b>",
                    :inline_format =>true
            end
    
            labelList = ""
            issue.labels.each do |label|
                if labelList != ""
                    labelList += ", "
                end
                labelList += label.name
            end
            output.text "<b>Labels:</b> #{labelList}",
                :inline_format =>true
            output.text "#{issue.body.gsub!(/\r\n?/,"  \n")}\n\n"
        end
        output.text "\n"
    end
    if options[:mess]
        output.render_file("#{File.split(repo)[1]}"+".pdf")
    else
        FileUtils.mkdir_p(File.split(repo)[0])
        output.render_file("#{repo}"+".pdf")
    end
end

def outputMarkdown(options, issueLabels, repo)
    if options[:mess]
        output = File.open("#{File.split(repo)[1]}"+".md","w")
    else
        FileUtils.mkdir_p(File.split(repo)[0])
        output = File.open("#{repo}"+".md","w")
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
                << "**Author:** " << issue.user.login << "  \n" \
               << "**Assignee:** "
            if issue.assignee 
                output << issue.assignee.login
            end
    
            output << "  \n**Labels:**"
            first = true
            issue.labels.each do |label|
                if not first
                    output << ","
                else
                    first = false
                end
                output << " " << label.name
            end
            output << "  \n" << issue.body.gsub(/\r\n?/,"  \n") << "  \n\n"
        end
        output << "\n------\n"
    end
    output.close
    return output
end

def outputText(options, issueLabels, repo)
    if options[:mess]
        output = File.open("#{File.split(repo)[1]}"+".txt","w")
    else
        FileUtils.mkdir_p(File.split(repo)[0])
        output = File.open("#{repo}"+".txt","w")
    end
    issueLabels.each do|epic|
        epicName = epic[0]
        output << epicName << "    \n"

        issueLabels[epicName].each do|issue|
            output << issue.title << "  \n" \
                << "Author: " << issue.user.login << "  \n" \
               << "Assignee: "
            if issue.assignee 
                output << issue.assignee.login
            end
    
            output << "  \nLabels:"
            first = true
            issue.labels.each do |label|
                if not first
                    output << ","
                else
                    first = false
                end
                output << " " << label.name
            end
            output << "  \n" << issue.body.gsub(/\r\n?/,"  \n") << "  \n\n"
        end
        output << "\n" << "-"*30 << "\n"
    end
    output.close
end

def scrapeIssues(options, client, repo)
    puts "Scraping Issues from " + repo + "... "
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
    if options[:pdf]
        outputPdf(options, issueLabels, repo)
    end
    if options[:markdown] or options[:html]
        mdOutput = outputMarkdown(options, issueLabels, repo)
    end
    if options[:html]
        system("perl ./Markdown.pl " + File.path(mdOutput) + " > " +
           File.path(mdOutput).gsub(/\.md$/,".html"))
    end
    if options[:text]
        outputText(options, issueLabels, repo)
    end
end
