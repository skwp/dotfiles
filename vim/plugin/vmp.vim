
if !exists('g:VMPoutputformat')
	let g:VMPoutputformat = 'html'
endif

if !exists('g:VMPoutputdirectory')
	let g:VMPoutputdirectory = '/tmp'
endif

if !exists('g:VMPhtmlreader')
	if has('mac')
		let g:VMPhtmlreader = 'open'
	elseif has('win32') || has('win64')
		let g:VMPhtmlreader = 'start'
	elseif has('unix') && executable('xdg-open')
		let g:VMPhtmlreader = 'xdg-open'
	else
		let g:VMPhtmlreader = ''
	end
endif

if !exists('g:VMPstylesheet')
	let g:VMPstylesheet = 'github.css'
endif


function! PreviewMKD()

ruby << RUBY

  runtime    = Vim.evaluate('&runtimepath').split(',')
  runtime.each { |path| $LOAD_PATH.unshift(File.join(path, 'plugin', 'vim-markdown-preview')) }

  css_base   = runtime.detect { |path| File.exists? File.join(path, 'plugin', 'vmp.vim') }
  stylesheet = File.join(css_base, 'plugin', 'vim-markdown-preview', 'stylesheets', 
                         Vim.evaluate('g:VMPstylesheet'))
  name       = Vim::Buffer.current.name.nil? ? 'Untitled' : File.basename(Vim::Buffer.current.name)
  output_dir = Vim.evaluate('g:VMPoutputdirectory')
  
  
  contents = Array.new(VIM::Buffer.current.count) { |i| VIM::Buffer.current[i + 1] }.join("\n")

  require('kramdown/kramdown')

  layout = <<-LAYOUT
   <!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

      <link rel="stylesheet"
            href="#{stylesheet}">
      </link>

      <title> #{name} </title>
      </head>
      <body>

        <div id="container">
          <div id="centered">
            <div id="article">
              <div class="page"> 
              #{Kramdown::Document.new(contents).to_html}
              </div>
            </div>
          </div>
        </div>

      </body>
    </html>
  LAYOUT

  case Vim.evaluate('g:VMPoutputformat')
    when 'html'
      reader = Vim.evaluate('g:VMPhtmlreader')

      if reader == ''
          Vim.message('No suitable HTML reader found! Please set g:VMPhtmlreader.')
      else
        file = File.join(output_dir, name + '.html')
        File.open(file, 'w') { |f| f.write(layout) }
        Vim.command("silent ! #{reader} '%s'" % [ file ])
        Vim.command 'redraw!'
      end
    when 'pdf'
      Vim.message('output format not implemented yet.')
    else
      Vim.message('Unrecongized output format! Check g:VMPoutputformat.')
    end

RUBY
endfunction

:command! Mm :call PreviewMKD()
