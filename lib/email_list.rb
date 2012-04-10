require 'active_support/core_ext/array/grouping'

class EmailList < Array
  def initialize(string_or_array)
    string_or_array ||= []
    super(process(string_or_array))
  end

  def process(string_or_array)
    string_or_array.strip! if string_or_array.is_a?(String)
    string_or_array.split(/[,;]\s*/).flatten
  end
end
