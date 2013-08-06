require 'aws'


module Muggy
  module Sdk
    include Muggy::Support::Memoisation
    extend self


    def reset_services!
      %w{auto_scaling
        cfn
        cloud_watch
        ec2
        elb
        elasticache
        r53
        s3
        sqs
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


    memoised :cloud_watch
    def cloud_watch!
      cloud_watch_for_region(Muggy.region)
    end

    def cloud_watch_for_region(region)
      ::AWS::CloudWatch.new(sdk_config(region: Muggy.formal_region(region)))
    end


    memoised :elasticache
    def elasticache!
      elasticache_for_region(Muggy.region)
    end

    def elasticache_for_region(region)
      ::AWS::Elasticache.new(sdk_config(region: Muggy.formal_region(region)))
    end


    memoised :sqs
    def sqs!
      sqs_for_region(Muggy.region)
    end

    def sqs_for_region(region)
      ::AWS::SQS.new(sdk_config(region: Muggy.formal_region(region)))
    end



    memoised :r53
    def r53!
      ::AWS::Route53.new(sdk_config())
    end


    def sdk_config(extra={})
      base_config.merge(extra)
    end


    def debug!
      ::AWS.config(:log_formatter => AWS::Core::LogFormatter.debug, :logger => Logger.new($stdout), :log_level => :debug)
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
