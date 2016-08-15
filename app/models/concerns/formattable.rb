module Formattable
  extend ActiveSupport::Concern

  included do
    def self.formattable(*properties)
      @formattable ||= Set.new
      @formattable += properties
    end

    def self.formattable_properties
      @formattable || [ ]
    end

    before_save :apply_formatting, if: -> {
      self.class.formattable_properties.any? { |property| changes.key? property }
    }
  end

protected

  def apply_formatting
    self.class.formattable_properties.each do |property|
      self.format_property property
    end
  end

  def format_property(property)
    result = Formatter.render send(property)
    self["formatted_#{property}"] = result
  end
end
