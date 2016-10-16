# frozen_string_literal: true
module ActiveRecord
  class Relation
    def chain
      yield(self) || self
    end
  end
end
