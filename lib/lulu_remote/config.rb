puts "CONFIG"

module LuluRemote

  def self.config
    @@config ||= LuluRemote.new
  end

  def self.configure
    yield config if block_given?
  end

  class LuluRemote 
    [:typical_lulu_delay, :username, :password, :download_dir ].each do |attr|
      attr_accessor attr
    end
  end
end



