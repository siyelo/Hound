require 'filtered_address_list'

describe FilteredAddressList do
  it "filters out hound addresses that already exist in parent message" do
    parent_mail = mock :fm_parent, all_addresses: ['1d@hound.cc', 'frank@f.com']
    mail = mock :fm, parent: parent_mail, all_addresses: ['1d@hound.cc', '2d@hound.cc']
    FilteredAddressList.new(mail).should == ['2d@hound.cc']
  end
end

