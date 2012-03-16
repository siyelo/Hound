# This class applies the rule that hound addresses in a reply should be
# ignored if they are the same as their parent hound addresses.
require 'hound_address_list'

class FilteredAddressList < Array
  def initialize(mail)
    super HoundAddressList.new(mail) - ParentHoundAddressList.new(mail)
  end
end
