require 'hound_address_list'

describe ParentHoundAddressList do
  it "extracts the hound addresses from the mail parent" do
    parent_mail = mock :fm_parent, all_addresses: ['1d@hound.cc', 'frank@f.com']
    mail = mock :fm, parent: parent_mail
    ParentHoundAddressList.new(mail).should == ['1d@hound.cc']
  end
end
