require 'digest'

class Token < String
  RANDOM_LIMIT = 1000

  def initialize(length = 40)
    super Digest::SHA1.hexdigest("--#{Time.now}--#{rand(RANDOM_LIMIT)}--")[0..length-1]
  end
end
