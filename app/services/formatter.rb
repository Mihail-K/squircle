class Formatter
  def self.render(*input)
    markdown.render *input
  end

private

  def self.markdown
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

  def self.renderer
    @renderer ||= Redcarpet::Render::HTML.new(
      escape_html: true, safe_links_only: true, link_attributes: { target: '_blank' }
    )
  end
end
