require 'aws'


module Muggy
  module Sdk
    extend self


    def reset_services!
      @auto_scaling = nil
      @cfn = nil
      @ec2 = nil
      @elb = nil
      @s3 = nil

      @base_config = nil
    end



    def auto_scaling
      @auto_scaling ||= auto_scaling_for_region(Muggy.region)
    end

    def auto_scaling_for_region(region)
      ::AWS::AutoScaling.new(sdk_config(region: Muggy.formal_region(region)))
    end


    def cfn
      @cfn ||= cfn_for_region(Muggy.region)
    end

    def cfn_for_region(region)
      ::AWS::CloudFormation.new(sdk_config(region: Muggy.formal_region(region)))
    end


    def ec2
      @ec2 ||= ec2_for_region(Muggy.region)
    end

    def ec2_for_region(region)
      ::AWS::EC2.new(sdk_config(region: Muggy.formal_region(region)))
    end


    def elb
      @elb ||= elb_for_region(Muggy.region)
    end

    def elb_for_region(region)
      ::AWS::ELB.new(sdk_config(region: Muggy.formal_region(region)))
    end




    def s3
      @s3 ||= s3_for_region(Muggy.region)
    end

    def s3_for_region(region)
      ::AWS::S3.new(sdk_config(region: Muggy.formal_region(region)))
    end



    def sdk_config(extra={})
      base_config.merge(extra)
    end


    def base_config
      @base_config ||= if Muggy.use_iam?
                         {credential_provider: AWS::Core::CredentialProviders::EC2Provider.new}
      # try to use .fog
      else
        fog_rc = File.expand_path(ENV['FOG_RC'] || "~/.fog")
        fog_credentials = YAML.load_file(fog_rc)[:default]
        {access_key_id: fog_credentials[:aws_access_key_id], secret_access_key: fog_credentials[:aws_secret_access_key]}
      end
    end
  end
end
