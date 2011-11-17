#!/usr/bin/env python
# -*- coding: utf-8 -*-
version = "0.1.3"

import os
import fileinput
import getopt
import sys
import re

# =============================================================================== 

class Dialect:
    shortcuts = {}
    synonyms = {}
    required = {}
    short_tags = ()

class HtmlDialect(Dialect):
    shortcuts = {
        'cc:ie': {
            'opening_tag': '<!--[if IE]>',
            'closing_tag': '<![endif]-->'},
        'cc:ie6': {
            'opening_tag': '<!--[if lte IE 6]>',
            'closing_tag': '<![endif]-->'},
        'cc:ie7': {
            'opening_tag': '<!--[if lte IE 7]>',
            'closing_tag': '<![endif]-->'},
        'cc:noie': {
            'opening_tag': '<!--[if !IE]><!-->',
            'closing_tag': '<!--<![endif]-->'},
        'html:4t': {
            'expand': True,
            'opening_tag':
                '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">\n' +
                '<html lang="en">\n' +
                '<head>\n' +
                '    ' + '<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />\n' +
                '    ' + '<title></title>\n' + 
                '</head>\n' +
                '<body>',
            'closing_tag':
                '</body>\n' +
                '</html>'},
        'html:4s': {
            'expand': True,
            'opening_tag':
                '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">\n' +
                '<html lang="en">\n' +
                '<head>\n' +
                '    ' + '<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />\n' +
                '    ' + '<title></title>\n' + 
                '</head>\n' +
                '<body>',
            'closing_tag':
                '</body>\n' +
                '</html>'},
        'html:xt': {
            'expand': True,
            'opening_tag':
                '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\n' +
                '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">\n' +
                '<head>\n' +
                '    ' + '<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />\n' +
                '    ' + '<title></title>\n' + 
                '</head>\n' +
                '<body>',
            'closing_tag':
                '</body>\n' +
                '</html>'},
        'html:xs': {
            'expand': True,
            'opening_tag':
                '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">\n' +
                '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">\n' +
                '<head>\n' +
                '    ' + '<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />\n' +
                '    ' + '<title></title>\n' + 
                '</head>\n' +
                '<body>',
            'closing_tag':
                '</body>\n' +
                '</html>'},
        'html:xxs': {
            'expand': True,
            'opening_tag':
                '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">\n' +
                '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">\n' +
                '<head>\n' +
                '    ' + '<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />\n' +
                '    ' + '<title></title>\n' + 
                '</head>\n' +
                '<body>',
            'closing_tag':
                '</body>\n' +
                '</html>'},
        'html:5': {
            'expand': True,
            'opening_tag':
                '<!DOCTYPE html>\n' +
                '<html lang="en">\n' +
                '<head>\n' +
                '    ' + '<meta charset="UTF-8" />\n' +
                '    ' + '<title></title>\n' + 
                '</head>\n' +
                '<body>',
            'closing_tag':
                '</body>\n' +
                '</html>'},
        'input:button': {
            'name': 'input',
            'attributes': { 'class': 'button', 'type': 'button', 'name': '', 'value': '' }
            },
        'input:password': {
            'name': 'input',
            'attributes': { 'class': 'text password', 'type': 'password', 'name': '', 'value': '' }
            },
        'input:radio': {
            'name': 'input',
            'attributes': { 'class': 'radio', 'type': 'radio', 'name': '', 'value': '' }
            },
        'input:checkbox': {
            'name': 'input',
            'attributes': { 'class': 'checkbox', 'type': 'checkbox', 'name': '', 'value': '' }
            },
        'input:file': {
            'name': 'input',
            'attributes': { 'class': 'file', 'type': 'file', 'name': '', 'value': '' }
            },
        'input:text': {
            'name': 'input',
            'attributes': { 'class': 'text', 'type': 'text', 'name': '', 'value': '' }
            },
        'input:submit': {
            'name': 'input',
            'attributes': { 'class': 'submit', 'type': 'submit', 'value': '' }
            },
        'input:hidden': {
            'name': 'input',
            'attributes': { 'type': 'hidden', 'name': '', 'value': '' }
            },
        'script:src': {
            'name': 'script',
            'attributes': { 'src': '' }
            },
        'script:jquery': {
            'name': 'script',
            'attributes': { 'src': 'http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js' }
            },
        'script:jsapi': {
            'name': 'script',
            'attributes': { 'src': 'http://www.google.com/jsapi' }
            },
        'script:jsapix': {
            'name': 'script',
            'text': '\n    google.load("jquery", "1.3.2");\n    google.setOnLoadCallback(function() {\n        \n    });\n'
            },
        'link:css': {
            'name': 'link',
            'attributes': { 'rel': 'stylesheet', 'type': 'text/css', 'href': '', 'media': 'all' },
            },
        'link:print': {
            'name': 'link',
            'attributes': { 'rel': 'stylesheet', 'type': 'text/css', 'href': '', 'media': 'print' },
            },
        'link:favicon': {
            'name': 'link',
            'attributes': { 'rel': 'shortcut icon', 'type': 'image/x-icon', 'href': '' },
            },
        'link:touch': {
            'name': 'link',
            'attributes': { 'rel': 'apple-touch-icon', 'href': '' },
            },
        'link:rss': {
            'name': 'link',
            'attributes': { 'rel': 'alternate', 'type': 'application/rss+xml', 'title': 'RSS', 'href': '' },
            },
        'link:atom': {
            'name': 'link',
            'attributes': { 'rel': 'alternate', 'type': 'application/atom+xml', 'title': 'Atom', 'href': '' },
            },
        'meta:ie7': {
            'name': 'meta',
            'attributes': { 'http-equiv': 'X-UA-Compatible', 'content': 'IE=7' },
            },
        'meta:ie8': {
            'name': 'meta',
            'attributes': { 'http-equiv': 'X-UA-Compatible', 'content': 'IE=8' },
            },
        'form:get': {
            'name': 'form',
            'attributes': { 'method': 'get' },
            },
        'form:g': {
            'name': 'form',
            'attributes': { 'method': 'get' },
            },
        'form:post': {
            'name': 'form',
            'attributes': { 'method': 'post' },
            },
        'form:p': {
            'name': 'form',
            'attributes': { 'method': 'post' },
            },
        }
    synonyms = {
        'checkbox': 'input:checkbox',
        'check': 'input:checkbox',
        'input:c': 'input:checkbox',
        'button': 'input:button',
        'input:b': 'input:button',
        'input:h': 'input:hidden',
        'hidden': 'input:hidden',
        'submit': 'input:submit',
        'input:s': 'input:submit',
        'radio': 'input:radio',
        'input:r': 'input:radio',
        'text': 'input:text',
        'passwd': 'input:password',
        'password': 'input:password',
        'pw': 'input:password',
        'input:t': 'input:text',
        'linkcss': 'link:css',
        'scriptsrc': 'script:src',
        'jquery': 'script:jquery',
        'jsapi': 'script:jsapi',
        'html5': 'html:5',
        'html4': 'html:4s',
        'html4s': 'html:4s',
        'html4t': 'html:4t',
        'xhtml': 'html:xxs',
        'xhtmlt': 'html:xt',
        'xhtmls': 'html:xs',
        'xhtml11': 'html:xxs',
        'opt': 'option',
        'st': 'strong',
        'css': 'style',
        'csss': 'link:css',
        'css:src': 'link:css',
        'csssrc': 'link:css',
        'js': 'script',
        'jss': 'script:src',
        'js:src': 'script:src',
        'jssrc': 'script:src',
        }
    short_tags = (
        'area', 'base', 'basefont', 'br', 'embed', 'hr', \
        'input', 'img', 'link', 'param', 'meta')
    required = {
        'a':      {'href':''},
        'base':   {'href':''},
        'abbr':   {'title': ''},
        'acronym':{'title': ''},
        'bdo':    {'dir': ''},
        'link':   {'rel': 'stylesheet', 'href': ''},
        'style':  {'type': 'text/css'},
        'script': {'type': 'text/javascript'},
        'img':    {'src':'', 'alt':''},
        'iframe': {'src': '', 'frameborder': '0'},
        'embed':  {'src': '', 'type': ''},
        'object': {'data': '', 'type': ''},
        'param':  {'name': '', 'value': ''},
        'form':   {'action': '', 'method': 'post'},
        'table':  {'cellspacing': '0'},
        'input':  {'type': '', 'name': '', 'value': ''},
        'base':   {'href': ''},
        'area':   {'shape': '', 'coords': '', 'href': '', 'alt': ''},
        'select': {'name': ''},
        'option': {'value': ''},
        'textarea':{'name': ''},
        'meta':   {'content': ''},
    }

class Parser:
    """The parser.
    """

    # Constructor
    # --------------------------------------------------------------------------- 

    def __init__(self, options=None, str='', dialect=HtmlDialect()):
        """Constructor.
        """

        self.tokens = []
        self.str = str
        self.options = options
        self.dialect = dialect
        self.root = Element(parser=self)
        self.caret = []
        self.caret.append(self.root)
        self._last = []

    # Methods 
    # --------------------------------------------------------------------------- 

    def load_string(self, str):
        """Loads a string to parse.
        """

        self.str = str
        self._tokenize()
        self._parse()

    def render(self):
        """Renders.
        Called by [[Router]].
        """

        # Get the initial render of the root node
        output = self.root.render()

        # Indent by whatever the input is indented with
        indent = re.findall("^[\r\n]*(\s*)", self.str)[0]
        output = indent + output.replace("\n", "\n" + indent)

        # Strip newline if not needed
        if self.options.has("no-last-newline") \
            or self.prefix or self.suffix:
            output = re.sub(r'\n\s*$', '', output)

        # TextMate mode
        if self.options.has("textmate"):
            output = self._textmatify(output)

        return output

    # Protected methods 
    # --------------------------------------------------------------------------- 

    def _textmatify(self, output):
        """Returns a version of the output with TextMate placeholders in it.
        """

        matches = re.findall(r'(></)|("")|(\n\s+)\n|(.|\s)', output)
        output = ''
        n = 1
        for i in matches:
            if i[0]:
                output += '>$%i</' % n
                n += 1
            elif i[1]:
                output += '"$%i"' % n
                n += 1
            elif i[2]:
                output += i[2] + '$%i\n' % n
                n += 1
            elif i[3]:
                output += i[3]
        output += "$0"
        return output

    def _tokenize(self):
        """Tokenizes.
        Initializes [[self.tokens]].
        """

        str = self.str.strip()

        # Find prefix/suffix
        while True:
            match = re.match(r"^(\s*<[^>]+>\s*)", str)
            if match is None: break
            if self.prefix is None: self.prefix = ''
            self.prefix += match.group(0)
            str = str[len(match.group(0)):]

        while True:
            match = re.findall(r"(\s*<[^>]+>[\s\n\r]*)$", str)
            if not match: break
            if self.suffix is None: self.suffix = ''
            self.suffix = match[0] + self.suffix
            str = str[:-len(match[0])]

        # Split by the element separators
        for token in re.split('(<|>|\+(?!\\s*\+|$))', str):
            if token.strip() != '':
                self.tokens.append(Token(token, parser=self))

    def _parse(self):
        """Takes the tokens and does its thing.
        Populates [[self.root]].
        """

        # Carry it over to the root node.
        if self.prefix or self.suffix:
            self.root.prefix = self.prefix
            self.root.suffix = self.suffix
            self.root.depth += 1

        for token in self.tokens:
            if token.type == Token.ELEMENT:
                # Reset the "last elements added" list. We will
                # repopulate this with the new elements added now.
                self._last[:] = []

                # Create [[Element]]s from a [[Token]].
                # They will be created as many as the multiplier specifies,
                # multiplied by how many carets we have
                count = 0
                for caret in self.caret:
                    local_count = 0
                    for i in range(token.multiplier):
                        count += 1
                        local_count += 1
                        new = Element(token, caret,
                                count = count,
                                local_count = local_count,
                                parser = self)
                        self._last.append(new)
                        caret.append(new)

            # For >
            elif token.type == Token.CHILD:
                # The last children added.
                self.caret[:] = self._last

            # For <
            elif token.type == Token.PARENT:
                # If we're the root node, don't do anything
                parent = self.caret[0].parent
                if parent is not None:
                    self.caret[:] = [parent]
        return

    # Properties
    # --------------------------------------------------------------------------- 

    # Property: dialect
    # The dialect of XML
    dialect = None

    # Property: str
    # The string
    str = ''

    # Property: tokens
    # The list of tokens
    tokens = []

    # Property: options
    # Reference to the [[Options]] instance
    options = None

    # Property: root
    # The root [[Element]] node.
    root = None 

    # Property: caret
    # The current insertion point.
    caret = None

    # Property: _last
    # List of the last appended stuff
    _last = None

    # Property: indent
    # Yeah
    indent = ''

    # Property: prefix
    # (String) The trailing tag in the beginning.
    #
    # Description:
    # For instance, in `<div>ul>li</div>`, the `prefix` is `<div>`.
    prefix = ''

    # Property: suffix
    # (string) The trailing tag at the end.
    suffix = ''
    pass

# =============================================================================== 

class Element:
    """An element.
    """

    def __init__(self, token=None, parent=None, count=None, local_count=None, \
                 parser=None, opening_tag=None, closing_tag=None, \
                 attributes=None, name=None, text=None):
        """Constructor.

        This is called by ???.

        Description:
        All parameters are optional.

        token       - (Token) The token (required)
        parent      - (Element) Parent element; `None` if root
        count       - (Int) The number to substitute for `&` (e.g., in `li.item-$`)
        local_count - (Int) The number to substitute for `$` (e.g., in `li.item-&`)
        parser      - (Parser) The parser

        attributes  - ...
        name        - ...
        text        - ...
        """

        self.children = []
        self.attributes = {}
        self.parser = parser

        if token is not None:
            # Assumption is that token is of type [[Token]] and is
            # a [[Token.ELEMENT]].
            self.name        = token.name
            self.attributes  = token.attributes.copy()
            self.text        = token.text
            self.populate    = token.populate
            self.expand      = token.expand
            self.opening_tag = token.opening_tag
            self.closing_tag = token.closing_tag

        # `count` can be given. This will substitude & in classname and ID
        if count is not None:
            for key in self.attributes:
                attrib = self.attributes[key]
                attrib = attrib.replace('&', ("%i" % count))
                if local_count is not None:
                    attrib = attrib.replace('$', ("%i" % local_count))
                self.attributes[key] = attrib

        # Copy over from parameters
        if attributes: self.attributes = attribues
        if name:       self.name       = name
        if text:       self.text       = text

        self._fill_attributes()

        self.parent = parent
        if parent is not None:
            self.depth = parent.depth + 1

        if self.populate: self._populate()

    def render(self):
        """Renders the element, along with it's subelements, into HTML code.

        [Grouped under "Rendering methods"]
        """

        output = ""
        try:    spaces_count = int(self.parser.options.options['indent-spaces'])
        except: spaces_count = 4
        spaces = ' ' * spaces_count
        indent = self.depth * spaces
        
        prefix, suffix = ('', '')
        if self.prefix: prefix = self.prefix + "\n"
        if self.suffix: suffix = self.suffix

        # Make the guide from the ID (/#header), or the class if there's no ID (/.item)
        # This is for the start-guide, end-guide and post-tag-guides
        guide_str = ''
        if 'id' in self.attributes:
            guide_str += "#%s" % self.attributes['id']
        elif 'class' in self.attributes:
            guide_str += ".%s" % self.attributes['class'].replace(' ', '.')

        # Build the post-tag guide (e.g., </div><!-- /#header -->),
        # the start guide, and the end guide.
        guide = ''
        start_guide = ''
        end_guide = ''
        if ((self.name == 'div') and \
            (('id' in self.attributes) or ('class' in self.attributes))):

            if (self.parser.options.has('post-tag-guides')):
                guide = "<!-- /%s -->" % guide_str

            if (self.parser.options.has('start-guide-format')):
                format = self.parser.options.get('start-guide-format')
                try: start_guide = format % guide_str
                except: start_guide = (format + " " + guide_str).strip()
                start_guide = "%s<!-- %s -->\n" % (indent, start_guide)

            if (self.parser.options.has('end-guide-format')):
                format = self.parser.options.get('end-guide-format')
                try: end_guide = format % guide_str
                except: end_guide = (format + " " + guide_str).strip()
                end_guide = "\n%s<!-- %s -->" % (indent, end_guide)

        # Short, self-closing tags (<br />)
        short_tags = self.parser.dialect.short_tags

        # When it should be expanded..
        # (That is, <div>\n...\n</div> or similar -- wherein something must go
        # inside the opening/closing tags)
        if  len(self.children) > 0 \
            or self.expand \
            or prefix or suffix \
            or (self.parser.options.has('expand-divs') and self.name == 'div'):

            for child in self.children:
                output += child.render()

            # For expand divs: if there are no children (that is, `output`
            # is still blank despite above), fill it with a blank line.
            if (output == ''): output = indent + spaces + "\n"

            # If we're a root node and we have a prefix or suffix...
            # (Only the root node can have a prefix or suffix.)
            if prefix or suffix:
                output = "%s%s%s%s%s\n" % \
                    (indent, prefix, output, suffix, guide)

            # Uh..
            elif self.name != '' or \
                 self.opening_tag is not None or \
                 self.closing_tag is not None:
                output = start_guide + \
                         indent + self.get_opening_tag() + "\n" + \
                         output + \
                         indent + self.get_closing_tag() + \
                         guide + end_guide + "\n"
            

        # Short, self-closing tags (<br />)
        elif self.name in short_tags: 
            output = "%s<%s />\n" % (indent, self.get_default_tag())

        # Tags with text, possibly
        elif self.name != '' or \
             self.opening_tag is not None or \
             self.closing_tag is not None:
            output = "%s%s%s%s%s%s%s%s" % \
                (start_guide, indent, self.get_opening_tag(), \
                 self.text, \
                 self.get_closing_tag(), \
                 guide, end_guide, "\n")

        # Else, it's an empty-named element (like the root). Pass.
        else: pass


        return output

    def get_default_tag(self):
        """Returns the opening tag (without brackets).

        Usage:
            element.get_default_tag()

        [Grouped under "Rendering methods"]
        """

        output = '%s' % (self.name)
        for key, value in self.attributes.iteritems():
            output += ' %s="%s"' % (key, value)
        return output

    def get_opening_tag(self):
        if self.opening_tag is None:
            return "<%s>" % self.get_default_tag()
        else:
            return self.opening_tag

    def get_closing_tag(self):
        if self.closing_tag is None:
            return "</%s>" % self.name
        else:
            return self.closing_tag

    def append(self, object):
        """Registers an element as a child of this element.

        Usage:
            element.append(child)

        Description:
        Adds a given element `child` to the children list of this element. It
        will be rendered when [[render()]] is called on the element.

        See also:
        - [[get_last_child()]]

        [Grouped under "Traversion methods"]
        """

        self.children.append(object)

    def get_last_child(self):
        """Returns the last child element which was [[append()]]ed to this element.

        Usage:
            element.get_last_child()

        Description:
        This is the same as using `element.children[-1]`.

        [Grouped under "Traversion methods"]
        """

        return self.children[-1]

    def _populate(self):
        """Expands with default items.

        This is called when the [[populate]] flag is turned on.
        """

        if self.name == 'ul':
            elements = [Element(name='li', parent=self, parser=self.parser)]

        elif self.name == 'dl':
            elements = [
                Element(name='dt', parent=self, parser=self.parser),
                Element(name='dd', parent=self, parser=self.parser)]

        elif self.name == 'table':
            tr = Element(name='tr', parent=self, parser=self.parser)
            td = Element(name='td', parent=tr, parser=self.parser)
            tr.children.append(td)
            elements = [tr]

        else:
            elements = []

        for el in elements:
            self.children.append(el)

    def _fill_attributes(self):
        """Fills default attributes for certain elements.

        Description:
        This is called by the constructor.

        [Protected, grouped under "Protected methods"]
        """

        # Make sure <a>'s have a href, <img>'s have an src, etc.
        required = self.parser.dialect.required

        for element, attribs in required.iteritems():
            if self.name == element:
                for attrib in attribs:
                    if attrib not in self.attributes:
                        self.attributes[attrib] = attribs[attrib]

    # ---------------------------------------------------------------------------

    # Property: last_child
    # [Read-only]
    last_child = property(get_last_child)

    # ---------------------------------------------------------------------------

    # Property: parent
    # (Element) The parent element.
    parent = None

    # Property: name
    # (String) The name of the element (e.g., `div`)
    name = ''

    # Property: attributes
    # (Dict) The dictionary of attributes (e.g., `{'src': 'image.jpg'}`)
    attributes = None

    # Property: children
    # (List of Elements) The children
    children = None

    # Property: opening_tag
    # (String or None) The opening tag. Optional; will use `name` and
    # `attributes` if this is not given.
    opening_tag = None

    # Property: closing_tag
    # (String or None) The closing tag
    closing_tag = None

    text = ''
    depth = -1
    expand = False
    populate = False
    parser = None

    # Property: prefix
    # Only the root note can have this.
    prefix = None
    suffix = None

# =============================================================================== 

class Token:
    def __init__(self, str, parser=None):
        """Token.

        Description:
        str   - The string to parse

        In the string `div > ul`, there are 3 tokens. (`div`, `>`, and `ul`)

        For `>`, it will be a `Token` with `type` set to `Token.CHILD`
        """

        self.str = str.strip()
        self.attributes = {}
        self.parser = parser

        # Set the type.
        if self.str == '<':
            self.type = Token.PARENT
        elif self.str == '>':
            self.type = Token.CHILD
        elif self.str == '+':
            self.type = Token.SIBLING
        else:
            self.type = Token.ELEMENT
            self._init_element()
        
    def _init_element(self):
        """Initializes. Only called if the token is an element token.
        [Private]
        """

        # Get the tag name. Default to DIV if none given.
        name = re.findall('^([\w\-:]*)', self.str)[0]
        name = name.lower().replace('-', ':')

        # Find synonyms through this thesaurus
        synonyms = self.parser.dialect.synonyms
        if name in synonyms.keys():
            name = synonyms[name]

        if ':' in name:
            try:    spaces_count = int(self.parser.options.get('indent-spaces'))
            except: spaces_count = 4
            indent = ' ' * spaces_count

            shortcuts = self.parser.dialect.shortcuts
            if name in shortcuts.keys():
                for key, value in shortcuts[name].iteritems():
                    setattr(self, key, value)
                if 'html' in name:
                    return
            else:
                self.name = name

        elif (name == ''): self.name = 'div'
        else: self.name = name

        # Look for attributes
        attribs = []
        for attrib in re.findall('\[([^\]]*)\]', self.str):
            attribs.append(attrib)
            self.str = self.str.replace("[" + attrib + "]", "")
        if len(attribs) > 0:
            for attrib in attribs:
                try:    key, value = attrib.split('=', 1)
                except: key, value = attrib, ''
                self.attributes[key] = value

        # Try looking for text
        text = None
        for text in re.findall('\{([^\}]*)\}', self.str):
            self.str = self.str.replace("{" + text + "}", "")
        if text is not None:
            self.text = text

        # Get the class names
        classes = []
        for classname in re.findall('\.([\$a-zA-Z0-9_\-\&]+)', self.str):
            classes.append(classname)
        if len(classes) > 0:
            try:    self.attributes['class']
            except: self.attributes['class'] = ''
            self.attributes['class'] += ' ' + ' '.join(classes)
            self.attributes['class'] = self.attributes['class'].strip()

        # Get the ID
        id = None
        for id in re.findall('#([\$a-zA-Z0-9_\-\&]+)', self.str): pass
        if id is not None:
            self.attributes['id'] = id

        # See if there's a multiplier (e.g., "li*3")
        multiplier = None
        for multiplier in re.findall('\*\s*([0-9]+)', self.str): pass
        if multiplier is not None:
            self.multiplier = int(multiplier)

        # Populate flag (e.g., ul+)
        flags = None
        for flags in re.findall('[\+\!]+$', self.str): pass
        if flags is not None:
            if '+' in flags: self.populate = True
            if '!' in flags: self.expand = True

    def __str__(self):
        return self.str 

    str = ''
    parser = None

    # For elements
    # See the properties of `Element` for description on these.
    name = ''
    attributes = None
    multiplier = 1
    expand = False
    populate = False
    text = ''
    opening_tag = None
    closing_tag = None

    # Type
    type = 0
    ELEMENT = 2 
    CHILD = 4
    PARENT = 8
    SIBLING = 16

# =============================================================================== 

class Router:
    """The router.
    """

    # Constructor 
    # --------------------------------------------------------------------------- 

    def __init__(self):
        pass

    # Methods 
    # --------------------------------------------------------------------------- 

    def start(self, options=None, str=None, ret=None):
        if (options):
            self.options = Options(router=self, options=options, argv=None)
        else:
            self.options = Options(router=self, argv=sys.argv[1:], options=None)

        if (self.options.has('help')):
            return self.help()

        elif (self.options.has('version')):
            return self.version()

        else:
            return self.parse(str=str, ret=ret)
    
    def help(self):
        print "Usage: %s [OPTIONS]" % sys.argv[0]
        print "Expands input into HTML."
        print ""
        for short, long, info in self.options.cmdline_keys:
            if "Deprecated" in info: continue 
            if not short == '': short = '-%s,' % short
            if not long  == '': long  = '--%s' % long.replace("=", "=XXX")

            print "%6s %-25s %s" % (short, long, info)
        print ""
        print "\n".join(self.help_content)

    def version(self):
        print "Uhm, yeah."

    def parse(self, str=None, ret=None):
        self.parser = Parser(self.options)

        try:
            # Read the files
            # for line in fileinput.input(): lines.append(line.rstrip(os.linesep))
            if str is not None:
                lines = str
            else:
                lines = [sys.stdin.read()]
                lines = " ".join(lines)

        except KeyboardInterrupt:
            pass

        except:
            sys.stderr.write("Reading failed.\n")
            return
            
        try:
            self.parser.load_string(lines)
            output = self.parser.render()
            if ret: return output
            sys.stdout.write(output)

        except:
            sys.stderr.write("Parse error. Check your input.\n")
            print sys.exc_info()[0]
            print sys.exc_info()[1]

    def exit(self):
        sys.exit()

    help_content = [
        "Please refer to the manual for more information.",
    ]

# =============================================================================== 

class Options:
    def __init__(self, router, argv, options=None):
        # Init self
        self.router = router

        # `options` can be given as a dict of stuff to preload
        if options:
            for k, v in options.iteritems():
                self.options[k] = v
            return

        # Prepare for getopt()
        short_keys, long_keys = "", []
        for short, long, info in self.cmdline_keys: # 'v', 'version'
            short_keys += short
            long_keys.append(long)

        try:
            getoptions, arguments = getopt.getopt(argv, short_keys, long_keys)

        except getopt.GetoptError:
            err = sys.exc_info()[1]
            sys.stderr.write("Options error: %s\n" % err)
            sys.stderr.write("Try --help for a list of arguments.\n")
            return router.exit()

        # Sort them out into options
        options = {}
        i = 0
        for option in getoptions:
            key, value = option # '--version', ''
            if (value == ''): value = True

            # If the key is long, write it
            if key[0:2] == '--':
                clean_key = key[2:]
                options[clean_key] = value

            # If the key is short, look for the long version of it
            elif key[0:1] == '-':
                for short, long, info in self.cmdline_keys:
                    if short == key[1:]:
                        print long
                        options[long] = True

        # Done
        for k, v in options.iteritems():
            self.options[k] = v

    def __getattr__(self, attr):
        return self.get(attr)

    def get(self, attr):
        try:    return self.options[attr]
        except: return None

    def has(self, attr):
        try:    return self.options.has_key(attr)
        except: return False

    options = {
        'indent-spaces': 4
    }
    cmdline_keys = [
        ('h', 'help', 'Shows help'),
        ('v', 'version', 'Shows the version'),
        ('', 'no-guides', 'Deprecated'),
        ('', 'post-tag-guides', 'Adds comments at the end of DIV tags'),
        ('', 'textmate', 'Adds snippet info (textmate mode)'),
        ('', 'indent-spaces=', 'Indent spaces'),
        ('', 'expand-divs', 'Automatically expand divs'),
        ('', 'no-last-newline', 'Skip the trailing newline'),
        ('', 'start-guide-format=', 'To be documented'),
        ('', 'end-guide-format=', 'To be documented'),
    ]
    
    # Property: router
    # Router
    router = 1

# =============================================================================== 

if __name__ == "__main__":
    z = Router()
    z.start()
