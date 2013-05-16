require 'aws'


module Muggy
  module Sdk
    extend self


    def reset_services!
      @ec2 = nil
      @cfn = nil
      @base_config = nil
    end


    def ec2
      @ec2 ||= ec2_for_region(Muggy.region)
    end

    def ec2_for_region(region)
      ::AWS::EC2.new(sdk_config(region: Muggy.formal_region(region)))
    end



    def cfn
      @cfn ||= cfn_for_region(Muggy.region)
    end

    def cfn_for_region(region)
      ::AWS::CloudFormation.new(sdk_config(region: Muggy.formal_region(region)))
    end



    def sdk_config(extra={})
      base_config.merge(extra)
    end


    def base_config
      @base_config ||= if Muggy.use_iam?
        {}

      # try to use .fog
      else
        fog_rc = File.expand_path(ENV['FOG_RC'] || "~/.fog")
        fog_credentials = YAML.load_file(fog_rc)[:default]
        {access_key_id: fog_credentials[:aws_access_key_id], secret_access_key: fog_credentials[:aws_secret_access_key]}
      end
    end
  end
end
