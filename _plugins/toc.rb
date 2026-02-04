require 'jekyll-toc'

module Jekyll
  class TocLiquidTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Get the page content
      page = context.registers[:page]
      content = page['content']
      
      # Generate TOC from the content
      Jekyll::TableOfContents::Parser.new(content).toc
    end
  end
end

Liquid::Template.register_tag('toc', Jekyll::TocLiquidTag)
