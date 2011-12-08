require File.dirname(__FILE__) + "/test_helper.rb"

THIS_YEAR=Time.now.year # todo

class RunningBinariesTest < Test::Unit::TestCase
  include RunsBinaryFixtures

  context "when running primary" do
    ["wordpress -h", "wordpress help"].each do |format|
      context "and getting help as a '#{format}'" do
        setup { @stdout, @stderr = bin(format) }

        should "have the command name and short description" do
          unless format == "wordpress -h" # doesn't apply to wordpress -h
            output_matches /NAME\n\s*wordpress\-help \- get help for a specific command/m
          end
        end

        should "have a local (not default) version string" do
          output_matches /0\.0\.1 \(c\) 2009 Nate Murray - local/
        end

        should "get a list of subcommands" do
          output_matches /subcommands/mi
        end

        should "have subcommand short descriptions" do
          output_matches /post\s*create a blog post/
          output_matches /categories\s*do something with categories/
          output_matches /help\s*get help for a specific command/
          output_matches /list\s*list blog postings/
        end

        should "have a usage" do
          output_matches /SYNOPSIS/i
          output_matches /wordpress(\-help)? \[/
        end

        should "be able to ask for help about help"
      end
    end

    context "and getting help as subcommand" do
      # ["wordpress -h", "wordpress help"].each do |format|
      ["wordpress help"].each do |format|
        context "'#{format}'" do
          should "get help on subcommand post"
        end
      end
    end

    context "with no options" do
      setup { @stdout, @stderr = bin("wordpress") }

      should "output the options" do
        output_matches /Primary Options:/
      end

      should "have the test_primary option" do
        output_matches /test_primary=>nil/
      end
    end
    should "be able to require 'primary' and run just fine"
  end
  
  context "when running with an action" do
    # should be the same for both formats
    ["wordpress-categories", "wordpress categories"].each do |bin_format|
      context "#{bin_format}" do

        context "with action block" do
          setup { @stdout, @stderr = bin("#{bin_format}") }
          should "have the parsed action items in the help output" do
            output_matches /sports news/m
          end
        end
      end
    end
  end
  
  context "callbacks" do
    context "on a binary" do
      setup { @stdout, @stderr = bin("wordpress") }

      %w(before after).each do |time|
        should "run the callback #{time}_run}" do
          assert @stdout.match(/#{time}_run command/)
        end
      end      
    end
    
    context "on help" do
      setup { @stdout, @stderr = bin("wordpress -h") }

      %w(before after).each do |time|
        should "not run the callback #{time}_run" do
          assert_nil @stdout.match(/#{time}_run command/)
        end
      end      
    end
    
  end
  

  context "when running the subcommand" do
    # should be the same for both formats
    ["wordpress-post", "wordpress post"].each do |bin_format|
      context "#{bin_format}" do

        context "with no options" do
          setup { @stdout, @stderr = bin("#{bin_format}") }
          should "fail because title is required" do
            output_matches /Error: option 'title' must be specified.\s*Try --help for help/m
          end
        end

        context "with options" do
          setup { @stdout, @stderr = bin("#{bin_format} --title='glendale'") }
          should "be running the subcommand's run block" do
            output_matches /Subcommand name/
          end
          should "have some default options" do
            output_matches /version=>false/
            output_matches /help=>false/
          end
          should "have some primary options" do
            output_matches /test_primary=>nil/
          end
          should "have some local options" do
            output_matches /title=>"glendale"/
            output_matches /type=>"html"/
          end
        end

        context "testing die statements" do
          setup { @stdout, @stderr = bin("#{bin_format} --title='glendale' --type=yaml") }

          should "die on invalid options"  do
            output_matches /argument \-\-type type must be one of \[html\|xhtml\|text\]/
          end
        end

      end # end bin_format
    end # end #each
  end

  ["wordpress help post", "wordpress post -h"].each do |format| 
    context "when calling '#{format}'" do
      
      setup { @stdout, @stderr = bin(format) }
      should "have a description" do
        output_matches /create a blog post/
      end

      should "have the proper usage line" do
        output_matches /SYNOPSIS\n\s*wordpress\-post/m
        output_matches /\[--title\]/
      end

      should "have option flags" do
        output_matches /\-\-title(.*)<s>/
      end

      should "have primary option flags" do
        output_matches /\-\-test-primary(.*)<s>/
      end

      should "have default option flags" do
        output_matches /\-\-verbose/
      end

      should "have trollop default option flags" do
        output_matches /\-e, \-\-version/
      end

      should "have the correct binary name and short description" do
        output_matches /NAME\n\s*wordpress\-post \- create a blog post/m
      end

      should "have a the primaries version string" do
         output_matches /0\.0\.1 \(c\) 2009 Nate Murray - local/
      end

      should "have options" do
        output_matches /Options/i

        output_matches /\-b, \-\-blog=<s>/
        output_matches /short name of the blog to use/

        output_matches /-i, \-\-title=<s>/
        output_matches /title for the post/
      end

    end
  end

  context "when running a bare primary" do
    ["flickr -h", "flickr help"].each do |format|
      context format do
        setup { @stdout, @stderr = bin(format) }

        should "have the name and short description" do
          unless format == "flickr -h" # hmm
            output_matches /NAME\n\s*flickr\-help \- get help for a specific command/m
          end
        end

        should "have a local (not default) version string" do
          output_matches /0\.0\.2 \(c\) #{Time.now.year}/
        end
      end
    end
    ["flickr-download -h", "flickr download -h"].each do |format|
      context format do
       setup { @stdout, @stderr = bin(format) }

       should "match on usage" do
         output_matches /SYNOPSIS\n\s*flickr\-download/m
       end
      end
    end
  end

end
