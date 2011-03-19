require 'tty_password_asker'
require 'digest/md5'
require 'ezcrypto'

# A Wallet is a file cyphered with a symmetric key derived from a password.
# This object maintains a set of key-values where the value is cyphered with the
# same key that cypher the complete wallet.
#
# I need to talk to cryptomens :)
class Wallet

    :public

    EXTENSION = "rwallet"

    def initialize(path, password_asker, algorithm = "blowfish")
        raise "Unknown algorithm '#{algorithm}', known algorithms: blowfish, aes256, des" unless %w{blowfish aes256 des}.include? algorithm
        @path = path
        @name = File.basename(@path, ".#{EXTENSION}")
        @password_asker = password_asker
        if FileTest.exist?(@path)
            data = Marshal.load(File.new(@path,"r"))
            @algorithm = data['algorithm']
            @cypherer = Wallet.build_crypto_key(@password_asker.ask_secret("[Opening #{@name} wallet]"), @algorithm)
            @secrets = Marshal.load(@cypherer.decrypt(data['passwords']))
        else
            @algorithm = algorithm
            @cypherer = Wallet.build_crypto_key(@password_asker.ask_new_secret("[Creating #{@name} wallet]"), @algorithm)
            @secrets = {}
        end
    end

    def entries
        @secrets.keys
    end

    def put(name, value = nil)
        if value.nil?
            value = @password_asker.ask_new_secret("[Creating #{name} value]")
        end
        @secrets[name] = @cypherer.encrypt(value)
    end

    def get(name)
        @cypherer.decrypt(@secrets[name])
    end

    def remove(name)
        @secrets.delete(name)
    end

    def save
        File.open(@path,"w") do |f|
            data = Hash.new
            data['algorithm'] = @algorithm
            data['passwords'] = @cypherer.encrypt(Marshal.dump(@secrets))
            f.write(Marshal.dump(data))
        end
    end
    
    def dump
      @secrets.keys.each do |k|
	puts "#{k}  =>  #{get k}"
      end
    end

    :private

    def self.build_crypto_key(secret, algorithm)
        EzCrypto::Key.with_password(secret, Digest::MD5.hexdigest(secret), :algorithm => algorithm)
    end

end
