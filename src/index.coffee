tagParser = /_?this\.([\w|_]*)\(/g
escapedTag = /[\w]*_$/

# Based on https://www.tutorialrepublic.com/html-reference/html5-tags.php
html5Tags = 'a article aside br details div h1 h2 h3 h4 h5 h6 header hgroup hr footer nav p section span summary
             button datalist fieldset form input keygen label legend meter optgroup option select textarea abbr
             acronym address b bdi bdo big blockquote center cite code del dfn em font i ins kbd mark output pre
             progress q rp rt ruby s samp small strike strong sub sup tt u var wbr dd dir dl dt li ol menu ul
             caption col colgroup table tbody td tfoot thead th tr applet area audio canvas embed figcaption
             figure frame frameset iframe img map noframes object param source time video'.split ' '

module.exports = class ReactTagsPlugin
  brunchPlugin: yes
  type: 'javascript'
  pattern: /\.js|\.coffee/

  constructor: (@config) ->
    @filter = @config?.plugins?.reactTags?.fileFilter or /^(app|test)/
    @blacklist = @config?.plugins?.reactTags?.blacklist or 'object data map var'.split(' ')
    @verbose = @config?.plugins?.reactTags?.verbose or no

  compile: (params, callback) ->
    source = params.data

    return callback null, data: source unless @filter.test(params.path)

    try
      blacklist = @blacklist
      taglist = []

      output = source.replace tagParser, (fragment, tag) ->
        return fragment if tag in blacklist

        if escapedTag.test(tag)
          shortTag = tag.substring(0, tag.length - 1)

          if shortTag in blacklist
            taglist.push shortTag unless shortTag in taglist
            return "React.createElement('#{ shortTag }', "

        if tag in html5Tags
          taglist.push tag unless tag in taglist
          return "React.createElement('#{ tag }', "

        return fragment

    catch err
      console.log "ERROR", err if @verbose
      return callback err.toString()

    console.log " - #{params.path}: #{ taglist.sort().join ', ' }" if @verbose and taglist.length > 0

    callback null, data: output
