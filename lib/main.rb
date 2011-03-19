#!/usr/bin/env ruby

require 'wallet'
require 'tty_password_asker'

# rwallet main ruby object


APP_NAME="rwallet"
APP_VERSION="1.1.0-alpha1"
APP_DESCRIPTION="rwallet is a command line wallet written in ruby and implemented
as a simple cyphered key value store meant to be used in unix shell scripts"
DATA_DIR = "#{ENV['HOME']}/.#{APP_NAME}"
Dir.mkdir(DATA_DIR) if not FileTest.exists?(DATA_DIR)

# Usage
def printusage error_code
    STDERR.puts "#{APP_NAME}-#{APP_VERSION} - #{APP_DESCRIPTION}

Usage:  #{APP_NAME} wallet_name command [OPTIONS..]

 Your wallets are in #{ENV['HOME']}/.#{APP_NAME}.
 Password and secrets are asked without echoing them.
 Prompt is written to stderr to allow using outputed secrets in scripts.

Available commands:
 create [algorithm]     Create a new wallet
 delete                 Delete a wallet
 put name [secret]      Put a new secret in a wallet
 get name               Get a secret from a wallet
 remove name            Remove a secret from a wallet

 Known algorithms are : blowfish, aes256 and des.
 Blowish is the default.

Examples (all using a 'foo' wallet)
 #{APP_NAME} foo create aes256         Create an empty wallet named 'foo' using the aes256 algorithm
 #{APP_NAME} foo delete                Delete the 'foo' wallet
 #{APP_NAME} foo list                  List all secrets from the 'foo' wallet
 #{APP_NAME} foo put bar secret        Save a secret named 'bar' in the 'foo' wallet
 #{APP_NAME} foo put bar               Ask for a new secret named 'bar' to be saved in the 'foo' wallet
 #{APP_NAME} foo get bar               Output the secret named 'bar' from the 'foo' wallet
 #{APP_NAME} foo remove bar            Remove the secret named 'bar' from the 'foo' wallet

Return status:
 0 if OK,
 1 is something went wrong

If you find a bug or would like a new feature to be added,
create a new issue in the github project: https://github.com/eskatos/rwallet"
    exit error_code
end


# check arguments

printusage(1) if ARGV.length < 2
wallet_name = ARGV[0]
wallet_path = "#{DATA_DIR}/#{wallet_name}.#{Wallet::EXTENSION}"
command = ARGV[1]
printusage(1) unless %w{create delete list put get remove dump}.include? command


# dispatch commands

password_asker = TtyPasswordAsker.new

begin
    case command

    when 'create'
        raise "Wallet '#{wallet_name}' already exists." if FileTest.exists?(wallet_path)
        if ARGV[2].nil?
            wallet = Wallet.new(wallet_path, password_asker)
        else
            wallet = Wallet.new(wallet_path, password_asker, ARGV[2])
        end
        wallet.save

    when 'delete'
	raise "Wallet '#{wallet_name}' does not exists." if not FileTest.exists?(wallet_path)
        if ARGV[2] != "iknowwhatiamdoing"                     # TODO : document me
            STDERR.puts "Type the following sentence to confirm deletion: \"I know what I am doing.\""
            raise "Bad spelling, deletion aborted!" if not STDIN.readline.chomp == "I know what I am doing."
        end
        File.delete(wallet_path)

    when 'list'
	raise "Wallet '#{wallet_name}' does not exists." if not FileTest.exists?(wallet_path)
        wallet = Wallet.new(wallet_path, password_asker)
        puts wallet.entries

    when 'put'
	raise "Wallet '#{wallet_name}' does not exists." if not FileTest.exists?(wallet_path)
        raise "put command need at least one argument: name " if ARGV[2].nil?
        wallet = Wallet.new(wallet_path, password_asker)
        wallet.put(ARGV[2],ARGV[3])
        wallet.save

    when 'get'
	raise "Wallet '#{wallet_name}' does not exists." if not FileTest.exists?(wallet_path)
        raise "get command need one argument: name " if ARGV[2].nil?
        wallet = Wallet.new(wallet_path, password_asker)
        puts wallet.get(ARGV[2])

    when 'remove'
        raise "Wallet '#{wallet_name}' does not exists." if not FileTest.exists?(wallet_path)
        raise "remove command need one argument: name " if ARGV[2].nil?
        wallet = Wallet.new(wallet_path, password_asker)
        wallet.remove(ARGV[2])
        wallet.save

    when 'dump'
        raise "Wallet '#{wallet_name}' does not exists." if not FileTest.exists?(wallet_path)
        wallet = Wallet.new(wallet_path, password_asker)
	wallet.dump
	
    end
rescue
    STDERR.puts "ERROR: " + $!.to_s
end
