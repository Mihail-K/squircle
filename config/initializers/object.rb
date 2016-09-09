class Object
  def chain
    yield(self) || self
  end
end
