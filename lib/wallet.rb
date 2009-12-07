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
            @passwords = Marshal.load(@cypherer.decrypt(data['passwords']))
        else
            @algorithm = algorithm
            @cypherer = Wallet.build_crypto_key(@password_asker.ask_new_secret("[Creating #{@name} wallet]"), @algorithm)
            @passwords = {}
        end
    end

    def entries
        @passwords.keys
    end

    def put(name, value = nil)
        if value.nil?
            value = @password_asker.ask_new_secret("[Creating #{name} value]")
        end
        @passwords[name] = @cypherer.encrypt(value)
    end

    def get(name)
        @cypherer.decrypt(@passwords[name])
    end

    def remove(name)
        @passwords.delete(name)
    end

    def save
        File.open(@path,"w") do |f|
            data = Hash.new
            data['algorithm'] = @algorithm
            data['passwords'] = @cypherer.encrypt(Marshal.dump(@passwords))
            f.write(Marshal.dump(data))
        end
    end

    :private

    def self.build_crypto_key(secret, algorithm)
        EzCrypto::Key.with_password(secret, Digest::MD5.hexdigest(secret), :algorithm => algorithm)
    end

end
