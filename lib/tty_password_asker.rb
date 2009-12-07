
# TtyPasswordAsker ask a secret string to the user using STDERR and without
# echoing using stty.
class TtyPasswordAsker


    :public

    def ask_secret(msg = nil)
        system "echo #{msg}>&2" if not msg.nil?
        ask_hidden("Secret:")
    end

    def ask_new_secret(msg = nil)
        system "echo #{msg}>&2" if not msg.nil?
        first = ask_hidden("New secret:")
        second = ask_hidden("Confirm secret:")
        raise "The two inputs differ" if first != second
        first
    end


    :private

    def ask_hidden(prompt = nil)
        STDOUT.flush
        STDERR.flush
        system "echo -n \"#{prompt}\">&2"
        begin
            system "stty -echo"
            password = STDIN.readline.chomp
        ensure
            system "stty echo"
            system "echo>&2"
        end
        password
    end

end
