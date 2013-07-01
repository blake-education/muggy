require 'fog'

module Muggy
  module Fog
    include Muggy::Support::Memoisation
    extend self

    # assumptions: Muggy.use_iam? is defined

    # reset service instances.
    # Used to reset memoised values if the global region's changed.
    def reset_services!
      %w{ 
        auto_scaling
        cache
        cfn
        cw
        ec2
        elb
        iam 
        rds
        r53
        s3
      }.each do |key|
        clear_memoised_value!(key)
      end
    end


    # services
    memoised :ec2
    def ec2!
      ec2_for_region(Muggy.region)
    end

    def ec2_for_region(region)
      ::Fog::Compute.new(provider: 'AWS', region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    memoised :elb
    def elb!
      elb_for_region(Muggy.region)
    end

    def elb_for_region(region)
      ::Fog::AWS::ELB.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    memoised :cache
    def cache!
      cache_for_region(Muggy.region)
    end

    def cache_for_region(region)
      ::Fog::AWS::Elasticache.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    memoised :cfn
    def cfn!
      cfn_for_region(Muggy.region)
    end

    def cfn_for_region(region)
      ::Fog::AWS::CloudFormation.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    memoised :s3
    def s3!
      s3_for_region(Muggy.region)
    end

    def s3_for_region(region)
      ::Fog::Storage.new(provider: 'AWS', region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    memoised :cw
    def cw!
      cloudwatch_for_region(Muggy.region)
    end

    def cloudwatch_for_region(region)
      ::Fog::AWS::CloudWatch.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    memoised :rds
    def rds!
      rds_for_region(Muggy.region)
    end

    def rds_for_region(region)
      ::Fog::AWS::RDS.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    memoised :auto_scaling
    def auto_scaling!
      auto_scaling_for_region(Muggy.region)
    end

    def auto_scaling_for_region(region)
      ::Fog::AWS::AutoScaling.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    #################
    #  region free  #
    #################


    memoised :r53
    def r53!
      ::Fog::DNS.new(provider: 'AWS', use_iam_profile: Muggy.use_iam?)
    end


    memoised :iam
    def iam!
      ::Fog::AWS::IAM.new()
    end


  end
end
