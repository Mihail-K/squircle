# frozen_string_literal: true
class Formatter
  attr_reader :input

  def initialize(*input)
    @input = input
  end

  def render
    markdown.render(*input)
  end

private

  def markdown
    @markdown ||= Redcarpet::Markdown.new(
      renderer,
      tables: true,
      autolink: true,
      underline: true,
      lax_spacing: true,
      strikethrough: true,
      no_intra_emphasis: true,
      disable_indented_code_blocks: true
    )
  end

  def renderer
    @renderer ||= Redcarpet::Render::HTML.new(
      escape_html: true, safe_links_only: true, link_attributes: { target: '_blank' }
    )
  end
end
