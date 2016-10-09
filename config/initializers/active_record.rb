module ActiveRecord
  class Relation
    def chain
      yield(self) || self
    end
  end
end
