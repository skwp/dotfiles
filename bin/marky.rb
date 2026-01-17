#!/usr/bin/env ruby

# source http://brettterpstra.com/marky-the-markdownifier-reintroductions/

require 'open-uri'
require 'net/http'
require 'iconv'
require 'optparse'
require 'fileutils'
require 'cgi'

$options = {}
# $fymdhost = "http://fym.dev"
$fymdhost = "http://heckyesmarkdown.com"

optparse = OptionParser.new do|opts|
	opts.banner = "Usage: #{File.basename(__FILE__)} [-o OUTPUT_PATH] -f TYPE [-t TYPE] input1 [input2, ...]"
	$options[:outfolder] = false
	opts.on( '-o DIR','--output DIR', 'Output folder, default STDOUT. Use "." for current folder, void if output type is "nv"' ) do |outfolder|
		filepath = File.expand_path(outfolder)
		unless File.exist?(filepath) && File.directory?(filepath)
			if File.exist?(filepath)
				puts "Output folder is not a directory"
				exit
			else
				FileUtils.mkdir_p(filepath)
				puts "Created #{filepath}"
			end
		end
		$options[:outfolder] = filepath.gsub(/\/$/,'') + "/"
		puts "Output folder: #{$options[:outfolder]}"
	end
	if STDIN.stat.nlink == 1
		if ARGV[-1] =~ /https?:/
			$options[:inputtype] = 'url'
		else
			$options[:inputtype] = case File.extname(File.expand_path(ARGV[-1]))
				when '.html' then 'htmlfile'
				when '.htm' then 'htmlfile'
				when '.txt' then 'htmlfile'
				when '.webarchive' then 'webarchive'
				when '.webloc' then 'bookmark'
				when '.webbookmark' then 'bookmark'
				else 'url'
			end
		end
	else
		$options[:inputtype] = 'html'
	end
	opts.on( '-f TYPE','--from TYPE', 'Input type (html, htmlfile, url [default], bookmark, webarchive, webarchiveurl)') do |input_type|
		$options[:inputtype] = input_type
	end
	$options[:outputtype] = 'md'
	opts.on( '-t TYPE', '--to TYPE', 'Output type (md [default], nv)') do |output_type|
		$options[:outputtype] = output_type
	end
	opts.on( '-h', '--help', 'Display this screen' ) do
		puts opts
		exit
	end
end

optparse.parse!
$input = STDIN.stat.nlink == 0 ? STDIN.read : ARGV

# Convert html input to readable Markdown
def html_to_markdown(input,filename = false)
	input = input.class == Array ? input.join : input
	res = Net::HTTP.post_form(URI.parse("#{$fymdhost}/go/"),{'html'=>input,'read'=>'1'})
	if res.code.to_i == 200
		if $options[:outfolder]
			outfile = $options[:outfolder]
			if filename
				outfile += File.basename(filename,'.html')+'.md'
			else
				outfile += res.body.split("\n")[2].gsub(/^#\s*/,'').strip.gsub(/[!?*$^()]+/,'') + '.md'
			end
			File.open(outfile,'w') {|f|
				f.puts res.body
			}
			puts "Markdown written to #{outfile}"
		else
			puts res.body
		end
	else
		puts "Error converting HTML"
	end
end

def html_file_to_markdown(outtype)
	$input.each {|file|
		input = File.expand_path(file)
		if File.exist?(input)
			html = File.open(input,'r') {|infile|
				CGI.escape(CGI.unescapeHTML(infile.read))
			}
			if outtype == 'md'
				html_to_markdown(html,input)
			else
				html_to_nv(html)
			end
		else
			puts "File does not exist: #{input}"
		end
	}
end

def url_to_markdown
	$input.each {|input|
		res = Net::HTTP.post_form(URI.parse("#{$fymdhost}/go/"),{'u'=>input,'read'=>'1'})
		if res.code.to_i == 200
			if $options[:outfolder]
				outfile = $options[:outfolder]
				outfile += input.gsub(/^https?:\/\//,'').strip.gsub(/\//,'_').gsub(/[!?*$^()]+/,'') + '.md'
				File.open(outfile,'w') {|f|
					f.puts res.body
				}
				puts "Markdown written to #{outfile}"
			else
				puts res.body
			end
		else
			puts "Error opening URL: #{input}"
		end
	}
end

# Convert html input to Markdown and add to nvALT
def html_to_nv(input)
	input = input.class == Array ? input.join : input
	res = Net::HTTP.post_form(URI.parse("#{$fymdhost}/go/"),{'html'=>input,'read'=>'1','output' => 'nv'})
	if res.code.to_i == 200
		%x{osascript -e 'tell app "nvALT" to activate'}
		%x{open "#{res.body}"}
	else
		puts "Error converting HTML"
	end
end

# Capture URL as Markdown note in nvALT
def url_to_nv
	$input.each {|input|
		res = Net::HTTP.post_form(URI.parse("#{$fymdhost}/go/"),{'u'=>input,'read'=>'1','output' => 'nv'})
		if res.code.to_i == 200
			%x{osascript -e 'tell app "nvALT" to activate'}
			%x{open "#{res.body}"}
		else
			puts "Error opening URL: #{input}"
		end
	}
end

# Convert url of web archive to Markdown
def webarchive_url_to_markdown(outtype)
	$input.each {|f|
		file = File.expand_path(f)
		source_url = %x{mdls -name 'kMDItemWhereFroms' -raw #{file}}.split("\n")[1].strip.gsub(/(^"|"$)/,'')
		res = Net::HTTP.post_form(URI.parse("#{$fymdhost}/go/"),{'u'=>source_url,'read'=>'1','output' => outtype})
		if res.code.to_i == 200
			if outtype == 'nv'
				%x{osascript -e 'tell app "nvALT" to activate'}
				%x{open "#{res.body}"}
			elsif ($options[:outfolder])
				outfile = $options[:outfolder]
				outfile += %x{textutil -info #{file} | grep "Title:"}.gsub(/^\s*Title:\s*/,'').strip.gsub(/[!?*$^()]+/,'') + '.md'
				File.open(outfile,'w') {|f|
					f.puts res.body
				}
				puts "Webarchive origin converted and saved to #{outfile}"
			else
				puts res.body
			end
		else
			puts "Error opening URL: #{source_url}"
		end
	}
end

# Convert webarchive contents to Markdown
def webarchive_to_markdown(outtype)
	$input.each {|f|
		file = File.expand_path(f)
		html = %x{textutil -convert html -noload -nostore -stdout #{file} 2> /dev/null}
		res = Net::HTTP.post_form(URI.parse("#{$fymdhost}/go/"),{'html'=>html,'read'=>'1','output' => outtype})
		if res.code.to_i == 200
			if outtype == 'nv'
				%x{osascript -e 'tell app "nvALT" to activate'}
				%x{open "#{res.body}"}
			elsif ($options[:outfolder])
				outfile = $options[:outfolder]
				outfile += %x{textutil -info #{file} | grep "Title:"}.gsub(/^\s*Title:\s*/,'').strip.gsub(/[!?*$^()]+/,'') + '.md'
				File.open(outfile,'w') {|out|
					out.puts res.body
				}
				puts "Webarchive converted and saved to #{outfile}"
			else
				puts res.body
			end
		else
			puts "Error converting HTML"
		end
	}
end

# Save the contents of a webbookmark or webloc url as Markdown
def bookmark_to_markdown(outtype)
	$input.each {|f|
		file = File.expand_path(f)
		if File.exist?(file)
			outfile = $options[:outfolder] ? $options[:outfolder] : ""
			outfile += %x{mdls -name 'kMDItemDisplayName' -raw "#{file}"}.strip.gsub(/(\.webbookmark|\.webloc)$/,'') + '.md'
			source_url = %x{mdls -name 'kMDItemURL' -raw "#{file}"}.strip
			if source_url.nil? || source_url == "(null)"
				source_url = File.open(file,'r') do |infile|
					ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
					urlstring = ic.iconv(infile.read + ' ')[0..-2].match(/\<key\>URL\<\/key\>\n\s*\<string\>(.*?)\<\/string\>/)
					urlstring.nil? ? nil : urlstring[1]
				end
			end
			if source_url.nil?
				puts "Could not locate URL for bookmark"
			else
				res = Net::HTTP.post_form(URI.parse("#{$fymdhost}/go/"),{'u'=>source_url,'read'=>'1','output' => outtype})
				if res.code.to_i == 200
					if outtype == 'nv'
						%x{osascript -e 'tell app "nvALT" to activate'}
						%x{open "#{res.body}"}
					elsif ($options[:outfolder])
						File.open(outfile,'w') {|f|
							f.puts res.body
						}
						puts "Bookmark converted and saved to #{outfile}"
					else
						puts res.body
					end
				else
					puts "Error opening URL: #{source_url}"
				end
			end
		end
	}
end

def bad_combo
	puts "Bad input/output combination"
	exit
end

if ($options[:inputtype] == 'url' || $options[:inputtype] == 'bookmark') && $input.class != Array
	p $input
	puts "Wrong argument format. This input type should be a space-separated list of urls or bookmark files."
	exit
end

if $options[:inputtype] == 'url'
	if $options[:outputtype] == 'md'
		url_to_markdown
	elsif $options[:outputtype] == 'nv'
		url_to_nv
	else
		bad_combo
	end
elsif $options[:inputtype] == 'html'
	if $options[:outputtype] == 'md'
		html_to_markdown($input)
	elsif $options[:outputtype] == 'nv'
		html_to_nv($input)
	else
		bad_combo
	end
elsif $options[:inputtype] == 'htmlfile'
	if $options[:outputtype] == 'md'
		html_file_to_markdown('md')
	elsif $options[:outputtype] == 'nv'
		html_file_to_markdown('nv')
	else
		bad_combo
	end
elsif $options[:inputtype] == 'bookmark'
	if $options[:outputtype] == 'md'
		bookmark_to_markdown('md')
	elsif $options[:outputtype] == 'nv'
		bookmark_to_nv('nv')
	else
		bad_combo
	end
elsif $options[:inputtype] == 'webarchiveurl'
	if $options[:outputtype] == 'md'
		webarchive_url_to_markdown('md')
	elsif $options[:outputtype] == 'nv'
		webarchive_url_to_nv('nv')
	else
		bad_combo
	end
elsif $options[:inputtype] == 'webarchive'
	if $options[:outputtype] == 'md'
		webarchive_to_markdown('md')
	elsif $options[:outputtype] == 'nv'
		webarchive_to_nv('nv')
	else
		bad_combo
	end
else
	bad_combo
end
