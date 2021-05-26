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

require 'json'
require 'thor'
require 'yaml'
require 'net/http'
require 'uri'

class TunnelVision < Thor

  class InvalidArgument < ::StandardError; end

  DEFAULT_APPLICATION = 'callrail'.freeze

  TUNNEL_HOST = 'pipe.cr-tunnel.xyz'.freeze
  TUNNEL_USER = 'exec'.freeze
  PORT_MAPPING_URL = "https://#{TUNNEL_HOST}/users.json".freeze
  VERSION = '0.1.0'

  CONFIG_FILE = File.expand_path('~/.tunnel-vision-config')

  method_option(
    :user,
    required: false,
    default: `whoami`.strip,
    aliases: '-u',
    desc: 'User for tunnel hostname'
  )
  method_option(
    :application,
    required: false,
    default: DEFAULT_APPLICATION,
    aliases: '-a',
    desc: 'Name of your target application (callrail, swappy, rowdy, ...)'
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
      "Automatically parsed from #{PORT_MAPPING_URL} if not specified."
  )

  desc 'start', 'Start an ssh tunnel for public access'
  long_desc <<-LONGDESC
    `start` can also read options from a config file.

    Any command line options will override values defined in the config file.

    For more information see:

    #{'https://github.com/abhchand/tunnel-vision#config-file'.underline}
    ```
  LONGDESC
  def start
    puts <<-DEBUG
tunnel-vision (v#{VERSION})

    Application:    #{"#{application}".colorize(:cyan)}
    Tunneling from: #{"#{TUNNEL_USER}@#{TUNNEL_HOST} (port: #{remote_port})".colorize(:cyan)}
    Tunneling to:   #{"#{local_hostname}:#{local_port}".colorize(:cyan)}

    Tunnel URL:     #{url.colorize(:cyan).underline}

    DEBUG

    config = "*:#{remote_port}:#{local_hostname}:#{local_port}"
    command = "ssh -nNT -g -R #{config} #{TUNNEL_USER}@#{TUNNEL_HOST}"

    puts "executing `#{command.colorize(:yellow)}`"
    exec command
  end

  desc 'version', 'Print the version'
  def version
    puts VERSION
  end

  private

  # Combine options from multiple sources into one unified options `Hash`
  # Returns all keys as `String` keys
  #
  # In order of highest precedence:
  #
  #   * Options specified on the command line
  #   * Options specified in the config file for this application
  #   * Default value defined in the `method_option`
  def opts
    @opts ||= begin
      application = command_line_options['application']

      (config_file_options[application] || {}).
        merge(command_line_options)
    end
  end

  # Return options specified on the command line by the user
  # Returns all keys as `String` keys
  def command_line_options
    @command_line_options ||= begin
      {}.tap do |str_options|
        options.each { |k,v| str_options[k.to_s] = v }
      end
    end
  end

  # Read options from the config file `CONFIG_FILE`
  # Returns {} if no config file is found.
  # Returns all keys as `String` keys
  def config_file_options
    @config_file_options ||= begin
      return {} unless File.exists?(CONFIG_FILE)

      puts "Reading from config file #{CONFIG_FILE}\n\n"
      JSON.parse(File.read(CONFIG_FILE))
    end
  end

  def application
    opts['application']
  end

  def user
    opts['user']
  end

  def local_hostname
    opts['local_hostname']
  end

  def local_port
    opts['local_port']
  end

  def remote_port
    @remote_port ||= begin
      # Try reading from the options, if specified
      return opts['remote_port'] if opts['remote_port']

      # Try to automatically determine this user's port mapping
      # A JSON mapping file should be available at `PORT_MAPPING_URL`

      uri = URI(PORT_MAPPING_URL)
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

  def cannot_determine_port!
    msg = "Can not determine #{user}'s remote port for #{application}."

    raise InvalidArgument, msg.colorize(:red)
  end
end

TunnelVision.start(ARGV)
