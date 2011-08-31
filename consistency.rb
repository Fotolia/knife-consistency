require 'chef/knife'

module Fotolia
  class Consistency < Chef::Knife

    banner "knife consistency [latest ENVIRONMENT|local]"

    deps do
      require 'chef/knife/search'
      require 'chef/environment'
      require 'chef/cookbook/metadata'
    end

    def run
      if name_args.count < 1 then
        ui.error "Usage : knife consistency [latest ENVIRONMENT|local]"
        exit 1
      end

      @action = name_args.first
      unless ["latest","local"].include?(@action)
        ui.error "You must specify a mode !"
        exit 1
      end

      if @action == "latest" then
        @environment = name_args[1]
      end

      case @action
        when "latest"
          target_versions = get_versions_from_env(@environment)
          latest_versions = get_latest_versions()

          latest_versions.each_pair do |name, cb_version|
            unless target_versions.has_key?(name)
              puts "cookbook \"#{name}\" has no version constraint in environment #{@environment} !"
              next
            end

            if target_versions[name] < cb_version then
              puts "cookbook \"#{name}\" is not up to date. latest is #{cb_version}, #{@environment} has version #{target_versions[name]}"
            end

          end


        when "local"
          local_versions = get_local_versions()
          latest_versions = get_latest_versions()
          
          latest_versions.each_pair do |name, cb_version|
            unless local_versions.has_key?(name)
              puts "cookbook \"#{name}\" has no local candidate version"
              next
            end

            if local_versions[name] < cb_version then
              puts "cookbook \"#{name}\" is not up to date. latest is #{cb_version}, local version is #{local_versions[name]}"
            end

          end
      end
    end

    # ger cookbook for a known environment
    def get_versions_from_env(env_name)
      cbs = {}
    
      env = Chef::Environment.load(env_name)
      env.cookbook_versions.each_pair do |name,version|
        cbs[name] = version.gsub("= ","")
      end
      return cbs
    end

    # get cookbook for the _default env, bleeding edge
    def get_latest_versions
      cbs = {}
      cookbook_versions = rest.get_rest("/environments/_default/cookbooks")
      cookbook_versions.each do |cookbook|
        cbs[cookbook[0]] = cookbook[1]["versions"][0]["version"]
      end
      return cbs
    end

    # in your local dealer !
    def get_local_versions
      cbs = {}
      if (ENV['HOME'] && File.exist?(File.join(ENV['HOME'], '.chef', 'knife.rb')))
        Chef::Config.from_file(File.join(ENV['HOME'], '.chef', 'knife.rb'))
      end

      Dir.glob("#{Chef::Config.cookbook_path}/*").each do |cookbook|
        md = Chef::Cookbook::Metadata.new

        cb_name = File.basename(cookbook)
        md.name(cb_name)
        md.from_file("#{cookbook}/metadata.rb")
        cbs[cb_name] = md.version
      end

      return cbs
    end

  end
end
