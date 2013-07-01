require 'aws'


module Muggy
  module Sdk
    include Muggy::Support::Memoisation
    extend self


    def reset_services!
      %w{auto_scaling
        cfn
        ec2
        elb
        s3
        base_config
      }.each do |key|
        clear_memoised_value!(key)
      end
    end



    memoised :auto_scaling

    def auto_scaling!
      auto_scaling_for_region(Muggy.region)
    end

    def auto_scaling_for_region(region)
      ::AWS::AutoScaling.new(sdk_config(region: Muggy.formal_region(region)))
    end


    memoised :cfn

    def cfn!
      cfn_for_region(Muggy.region)
    end

    def cfn_for_region(region)
      ::AWS::CloudFormation.new(sdk_config(region: Muggy.formal_region(region)))
    end


    memoised :ec2

    def ec2!
      ec2_for_region(Muggy.region)
    end

    def ec2_for_region(region)
      ::AWS::EC2.new(sdk_config(region: Muggy.formal_region(region)))
    end


    memoised :elb

    def elb!
      elb_for_region(Muggy.region)
    end

    def elb_for_region(region)
      ::AWS::ELB.new(sdk_config(region: Muggy.formal_region(region)))
    end


    memoised :s3

    def s3!
      s3_for_region(Muggy.region)
    end

    def s3_for_region(region)
      ::AWS::S3.new(sdk_config(region: Muggy.formal_region(region)))
    end



    def sdk_config(extra={})
      base_config.merge(extra)
    end


    memoised :base_config
    def base_config!
      if Muggy.use_iam?
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
