class EmailList < Array
  def initialize(string_or_array)
    string_or_array ||= []
    super(process(string_or_array))
  end

  def process(string_or_array)
    string_or_array.split(/[,;]\s*/).flatten
  end
end
