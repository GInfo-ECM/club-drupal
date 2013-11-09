#!/usr/bin/ruby -w
#encoding: UTF-8

require "dbi"
require "uri"

###### Definition of functions
def custom_chomp(string)
  # Chomp line completely
  previous_string = ''
  while string != previous_string
    previous_string = string.dup # = makes a reference to the original string
    string.chomp!
  end
  return string
end


def fix_issues_comment_link(name, cid2iid, cid2post_nb)
  # Fix links like : task-name#comment-789
  scan_regex = /.*#comment-(\d+)/
  cid = name.scan(scan_regex).flatten[0]
  post_nb = custom_chomp(cid2post_nb[cid])
  return "##{cid2iid[cid]}#note-#{post_nb}"
end


def fix_issues_link(text, name2iid, cid2iid, cid2post_nb)
  # Find all links in text
  scan_regex =  /:http:\/\/assos\.centrale-marseille\.fr(?:\/|\/lessive\/)(?:content(?:\/t(?:%C3%A2|â)che)?|node)\/([^ \n.,\/)]*)/

  # Non flattened output is [['some'], ['text']]
  # flattened output is ['some', 'text']
  names = text.scan(scan_regex).flatten

  if not names.empty?
    names.each do |name|
      name = custom_chomp(name)
      if name.include? 'é' or name.include? 'è' or name.include? 'ê' or name.include? 'à' or name.include? 'ô' or name.include? 'â' or name.include? 'ù' or name.include? 'û'
        name = URI.escape(name)
      end
      unescaped_name = URI.unescape(name)
      gsub_regex = /"http:\/\/assos\.centrale-marseille\.fr(?:\/|\/lessive\/)(?:content(?:\/t(?:%C3%A2|â)che)?|node)\/[^ ]*":http:\/\/assos\.centrale-marseille\.fr(?:\/|\/lessive\/)(?:content(?:\/t(?:%C3%A2|â)che)?|node)\/#{name}/
      # Some link may have a description between "…"
      if (text =~ gsub_regex)
        # Some comments are like this : task-name#comment-nb.
        # We fix them here
        if name.include? '#comment-'
          remplace_regex = fix_issues_comment_link(name, cid2iid, cid2post_nb)
        else
          remplace_regex = "#{unescaped_name} : ##{name2iid[name]}"
        end
        text.gsub!(gsub_regex, remplace_regex)
      else
        scan_regex = /"([^"]*)":http:\/\/assos\.centrale-marseille\.fr(?:\/|\/lessive\/)(?:content(?:\/t(?:%C3%A2|â)che)?|node)\/(?:[^ \n)]*)/
        description = text.scan(scan_regex).flatten[0]
        gsub_regex = /"#{description}":http:\/\/assos\.centrale-marseille\.fr(?:\/|\/lessive\/)(?:content(?:\/t(?:%C3%A2|â)che)?|node)\/#{name}/
        if name.include? '#comment-'
          remplace_regex = fix_issues_comment_link(name, cid2iid, cid2post_nb)
          remplace_regex = "#{description} (" + remplace_regex + ')'
        else
          remplace_regex = "#{description} (##{name2iid[name]})"
        end
        text.gsub!(gsub_regex, remplace_regex)
      end
    end
  end
  return text
end


def fix_comments_link(text, cid2iid, cid2post_nb)
  scan_regex = /:http:\/\/assos\.centrale-marseille\.fr(?:\/|\/lessive\/|\/portail\/)comment\/(\d+)/

  cids = text.scan(scan_regex).flatten

  if not cids.empty?
    cids.each do |cid|
      cid = custom_chomp(cid)
      gsub_regex = /"http:\/\/assos\.centrale-marseille\.fr(?:\/|\/lessive\/)comment\/.*":http:\/\/assos\.centrale-marseille\.fr(?:\/|\/lessive\/)comment\/#{cid}#comment-\d+/
      post_nb = custom_chomp(cid2post_nb[cid])
      # Some link may have a description between "…"
      if (text =~ gsub_regex)
        remplace_regex = "##{cid2iid[cid]}#note-#{post_nb}"
        text.gsub!(gsub_regex, remplace_regex)
      else
        scan_regex = /"([^"]*)":http:\/\/assos\.centrale-marseille\.fr(?:\/|\/lessive\/|\/portail\/)comment\/(?:\d+)/
        description = text.scan(scan_regex).flatten[0]
        gsub_regex = /"#{description}":http:\/\/assos\.centrale-marseille\.fr(?:\/|\/lessive\/)comment\/#{cid}#comment-\d+/
        remplace_regex = "#{description} (##{cid2iid[cid]}#note-#{post_nb})"
        text.gsub!(gsub_regex, remplace_regex)
      end
    end
  end
  return text
end



###### DATABASE
begin
  ##### Create DB connection
  db = 'redmine_default'
  dbuser = 'root'
  dbpwd = 'tata'
  host = 'localhost'
  dbh = DBI.connect("DBI:Mysql:#{db}:#{host}", dbuser, dbpwd)
  dbh.do("SET NAMES 'UTF8'")

  ###### Initialisation of hashes needed to fix URL
  name2iid = Hash.new
  cid2iid = Hash.new
  cid2post_nb = Hash.new

  fix_url_issues_csv = File.open("fix_url_issues.csv", "r")
  fix_url_issues_csv.each do |line|
    line = line.chomp
    nid, name, iid = line.split(',')
    name2iid[name] = iid
    name2iid[nid] = iid
  end
  fix_url_issues_csv.close

  fix_url_comments_csv = File.open("fix_url_comments.csv", "r")
  fix_url_comments_csv.each do |line|
    cid, iid, post_nb = line.split(',')
    cid2iid[cid] = iid
    cid2post_nb[cid] = post_nb
  end
  fix_url_comments_csv.close



  ###### Update issues
  sql_update_issue = "UPDATE issues SET author_id = ?, created_on = ?, is_private = 1 WHERE  id = ?"
  sql_fix_links_issue = "UPDATE issues SET description = ? WHERE id = ?"
  select_description = "SELECT description FROM issues WHERE id = ?"

  req_update_issue = dbh.prepare(sql_update_issue)
  req_fix_links_issue = dbh.prepare(sql_fix_links_issue)
  req_select_description = dbh.prepare(select_description)

  # Reading file
  issues = File.open('issues.csv', 'r')
  issues.each do |line|
    # Update author and date of creation
    line = line.chomp
    iid, author_id, created_on, nid, name = line.split(',')
    req_update_issue.execute(author_id, created_on, iid)

    ## Fix links
    # issues
    req_select_description.execute(iid)

    description = req_select_description.fetch[0]
    description = fix_issues_link(description, name2iid, cid2iid, cid2post_nb)

    # Comments
    description = fix_comments_link(description, cid2iid, cid2post_nb)

    # We update
    req_fix_links_issue.execute(description, iid)
  end

  req_select_description.finish
  req_update_issue.finish
  req_fix_links_issue.finish



  ###### Update journals
  sql_get_ids = "SELECT id FROM journals WHERE journalized_id = ? ORDER BY id ASC"
  sql_update_journals = "UPDATE journals SET created_on = ?, user_id = ? WHERE id = ?"
  sql_updated_on = "UPDATE issues SET  updated_on = ? WHERE id = ?"
  sql_fix_links_comment = "UPDATE journals SET notes = ? WHERE id = ?"

  req_get_ids = dbh.prepare(sql_get_ids)
  req_update_journals = dbh.prepare(sql_update_journals)
  req_updated_on = dbh.prepare(sql_updated_on)
  req_fix_links_comment = dbh.prepare(sql_fix_links_comment)

  # Reading file
  comments = File.open('comments.csv', 'r')

  # We must remember current iid in order to fetch result or execute query: req_get_id return
  # more than one value
  current_iid = -1
  select_notes = "SELECT notes FROM journals WHERE id = ?"
  req_select_notes = dbh.prepare(select_notes)

  comments.each do |line|
    line = line.chomp
    iid, user_id, created_on = line.split(',')

    # We get the id of the comment
    if iid != current_iid
      current_iid = iid
      req_get_ids.execute(iid)
    end

    id = req_get_ids.fetch[0]

    # We do the update
    req_update_journals.execute(created_on, user_id, id)
    req_updated_on.execute(created_on, iid)

    ## Fix links
    # issues
    req_select_notes.execute(id)
    notes = req_select_notes.fetch[0]
    notes = fix_issues_link(notes, name2iid, cid2iid, cid2post_nb)

    # Comments
    notes = fix_comments_link(notes, cid2iid, cid2post_nb)

    req_fix_links_comment.execute(notes, id)
  end
  comments.close

  req_select_notes.finish
  req_get_ids.finish
  req_update_journals.finish
  req_updated_on.finish
rescue DBI::DatabaseError => e
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
ensure
     # disconnect from server
     dbh.disconnect if dbh
end
