#!/usr/bin/env ruby

#
# tunnel-vision Ruby client
# Starts an SSH connection to the tunnel server
#
# See: https://github.com/abhchand/tunnel-vision
#
# Run `tunnel-vision --help` for menu

require 'bundler/inline'

gemfile true do
 source 'https://rubygems.org'
 gem 'colorize', '~> 0.8.1'
 gem 'thor', '~> 1.0', '>= 1.0.1'
end
puts "\n\n"

require 'thor'
require 'yaml'
require 'net/http'
require 'uri'

class TunnelVision < Thor

  class InvalidArgument < ::StandardError; end

  CONFIG_URL = 'https://raw.githubusercontent.com/abhchand/tunnel-vision/master/roles/tunnel-server/vars/main.yml'.freeze
  TUNNEL_URL = 'exec@pipe.cr-tunnel.xyz'.freeze

  method_option :user, required: true, aliases: '-u', desc: 'User for tunnel hostname'
  method_option(
    :local_hostname,
    required: false,
    default: '0.0.0.0',
    aliases: '-h',
    desc: 'Local hostname to forward requests to.'
  )
  method_option(
    :local_port,
    type: :numeric,
    required: false,
    default: 3000,
    aliases: '-p',
    desc: 'Port for your local development server'
  )
  method_option(
    :remote_port,
    type: :numeric,
    required: false,
    aliases: '-r',
    desc: 'Remote port to connect to on pipe server. ' +
      'Automatically parsed from remote config file if not specified.'
  )

  desc 'start', 'Start an ssh tunnel for public access'
  def start
    command = "ssh -nNT -g -R #{config} #{TUNNEL_URL}"

    puts "executing `#{command.colorize(:yellow)}`"
    exec command
  end

  private

  def user
    @user ||= options[:user]
  end

  def remote_port
    @remote_port ||= begin
      # Try reading from the options, if specified
      return options[:remote_port] if options[:remote_port]

      # Try to automatically determine this user's port from the ansible play
      # config file mapping

      uri = URI(CONFIG_URL)
      res = Net::HTTP.get_response(uri)

      cannot_determine_port! unless (200..299).include?(res.code.to_i)

      found_user = YAML.load(res.body)['tunnel_users'].detect do |u|
        u['name'] == user
      end
      cannot_determine_port! unless found_user

      found_user['unique_port']
    end
  end

  def config
    "*:#{remote_port}:#{options[:local_hostname]}:#{options[:local_port]}"
  end

  def cannot_determine_port!
    msg = 'Can not determine remote port. Please specify `-r` ' +
      "and ensure your user is configured at #{CONFIG_URL}}"
    raise InvalidArgument, msg.colorize(:red)
  end
end

TunnelVision.start(ARGV)
