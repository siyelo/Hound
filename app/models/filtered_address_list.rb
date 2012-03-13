# This class applies the rule that hound addresses in a reply should be 
# ignored if they are the same as their parent hound addresses.
class FilteredAddressList < Array
  def initialize(mail) 
    hounds = HoundAddressList.new(mail)
    parent_hounds = HoundAddressList.new(mail.parent)
    super hounds - parent_hounds
  end
end
