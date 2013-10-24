module FakeInstrumentation
  def instrument(event, payload = nil)
    (@instrumentations ||= []) << { event: event, payload: payload }
    yield payload if block_given?
  end

  def instrumentations
    @instrumentations
  end

  def last_instrumentation
    @instrumentations.try :last
  end
end
