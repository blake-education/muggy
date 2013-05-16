require 'fog'

module Muggy
  module Fog
    # assumptions: Muggy.use_iam? is defined

    # reset service instances.
    # Used to reset memoised values if the global region's changed.
    def reset_services!
      @ec2 = nil
      @cfn = nil
      @s3  = nil
      @cw  = nil
      @iam = nil
      @elb = nil
      @rds = nil
      @r53 = nil
      @cache = nil
      @auto_scaling = nil
    end


    # services
    def ec2
      @ec2 ||= ec2_for_region(Muggy.region)
    end

    def ec2_for_region(region)
      ::Fog::Compute.new(provider: 'AWS', region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    def elb
      @elb ||= elb_for_region(Muggy.region)
    end

    def elb_for_region(region)
      ::Fog::AWS::ELB.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    def cache
      @cache ||= cache_for_region(Muggy.region)
    end

    def cache_for_region(region)
      ::Fog::AWS::Elasticache.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    def cfn
      @cfn ||= cfn_for_region(Muggy.region)
    end

    def cfn_for_region(region)
      ::Fog::AWS::CloudFormation.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    def s3
      @s3 ||= s3_for_region(Muggy.region)
    end

    def s3_for_region(region)
      ::Fog::Storage.new(provider: 'AWS', region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    def cw
      @cw ||= cloudwatch_for_region(Muggy.region)
    end

    def cloudwatch_for_region(region)
      ::Fog::AWS::CloudWatch.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    def rds
      @rds ||= rds_for_region(Muggy.region)
    end

    def rds_for_region(region)
      ::Fog::AWS::RDS.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    def auto_scaling
      @auto_scaling ||= auto_scaling_for_region(Muggy.region)
    end

    def auto_scaling_for_region(region)
      ::Fog::AWS::AutoScaling.new(region: Muggy.formal_region(region), use_iam_profile: Muggy.use_iam?)
    end


    #################
    #  region free  #
    #################


    def r53
      @r53 ||= ::Fog::DNS.new(provider: 'AWS', use_iam_profile: Muggy.use_iam?)
    end

    def iam
      @iam ||= ::Fog::AWS::IAM.new()
    end


    extend self
  end
end
