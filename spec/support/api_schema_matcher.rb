# frozen_string_literal: true
RSpec::Matchers.define :match_response_schema do |schema|
  match do |response|
    schema_directory = "#{Dir.pwd}/spec/support/api/schemas"
    schema_path      = "#{schema_directory}/#{schema}.json"

    @result = JSON::Validator.fully_validate(schema_path, response.body, validate_schema: true)
    @result.blank?
  end

  failure_message do |actual|
    "expected #{actual} to match response schema #{schema}\n." + @result.join('. ')
  end

  failure_message_when_negated do |actual|
    "expected #{actual} not to match response schema #{schema}\n." + @result.join('. ')
  end
end
