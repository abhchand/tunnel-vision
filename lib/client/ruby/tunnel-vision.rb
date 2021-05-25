#!/usr/bin/env ruby

#
# tunnel-vision Ruby client
# Starts an SSH connection to the tunnel server
#
# See: https://github.com/abhchand/tunnel-vision
#
# Run `tunnel-vision --help` for menu

require 'bundler/inline'

begin
  original_stdout = $stdout
  $stdout = File.open(File::NULL, 'w')

  gemfile true do
   source 'https://rubygems.org'
   gem 'colorize', '~> 0.8.1'
   gem 'thor', '~> 1.0', '>= 1.0.1'
  end
ensure
  $stdout = original_stdout
end

require 'thor'
require 'yaml'
require 'net/http'
require 'uri'

class TunnelVision < Thor

  class InvalidArgument < ::StandardError; end

  DEFAULT_APPLICATION = 'callrail'.freeze

  TUNNEL_HOST = 'pipe.cr-tunnel.xyz'.freeze
  TUNNEL_USER = 'exec'.freeze
  VERSION = '0.1.0'

  method_option(
    :user,
    required: false,
    default: `whoami`,
    aliases: '-u',
    desc: 'User for tunnel hostname'
  )
  method_option(
    :application,
    required: false,
    default: DEFAULT_APPLICATION,
    aliases: '-a',
    desc: 'Name of your target application'
  )
  method_option(
    :local_hostname,
    required: false,
    default: '0.0.0.0',
    aliases: '-h',
    desc: 'Local hostname of your target application'
  )
  method_option(
    :local_port,
    type: :numeric,
    required: false,
    default: 3000,
    aliases: '-p',
    desc: 'Local port number of your target application'
  )
  method_option(
    :remote_port,
    type: :numeric,
    required: false,
    aliases: '-r',
    desc: 'Remote port to connect to on pipe server. ' +
      'Automatically parsed from remote config if not specified.'
  )

  desc 'start', 'Start an ssh tunnel for public access'
  def start
    puts <<-DEBUG
tunnel-vision (v#{VERSION})

    Application:    #{"#{application}".colorize(:cyan)}
    Tunneling from: #{"#{TUNNEL_USER}@#{TUNNEL_HOST} (port: #{remote_port})".colorize(:cyan)}
    Tunneling to:   #{"#{local_hostname}:#{local_port}".colorize(:cyan)}

    Tunnel URL:     #{url.colorize(:cyan).underline}

    DEBUG

    command = "ssh -nNT -g -R #{config} #{TUNNEL_USER}@#{TUNNEL_HOST}"

    puts "executing `#{command.colorize(:yellow)}`"
    exec command
  end

  desc 'version', 'Print the version'
  def version
    puts VERSION
  end

  private

  def application
    options[:application]
  end

  def user
    options[:user]
  end

  def local_hostname
    options[:local_hostname]
  end

  def local_port
    options[:local_port]
  end

  def remote_port
    @remote_port ||= begin
      # Try reading from the options, if specified
      return options[:remote_port] if options[:remote_port]

      # Try to automatically determine this user's port mapping
      # A JSON mapping file should be available at
      #   "https://#{TUNNEL_HOST}/users.json"

      uri = URI("https://#{TUNNEL_HOST}/users.json")
      res = Net::HTTP.get_response(uri)

      cannot_determine_port! unless (200..299).include?(res.code.to_i)

      found_user = YAML.load(res.body)[user]
      cannot_determine_port! unless found_user
      cannot_determine_port! unless found_user.key?(application)

      found_user[application]
    end
  end

  def url
    subdomain = [user]
    subdomain << application if application != DEFAULT_APPLICATION

    "https://#{subdomain.join('-')}.#{TUNNEL_HOST}"
  end

  def config
    "*:#{remote_port}:#{local_hostname}:#{local_port}"
  end

  def cannot_determine_port!
    msg = "Can not determine remote port for #{application}. Please specify `-r` " +
      "or ensure your remote user is configured correctly."
    raise InvalidArgument, msg.colorize(:red)
  end
end

TunnelVision.start(ARGV)
