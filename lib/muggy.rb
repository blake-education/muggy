require "muggy/version"
require 'socket'
require 'pathname'


module Muggy
  ## formal regions

  # attributes affecting AWS API connections
  def regions
    @regions ||= %w{
        us-east-1
        us-west-2
        ap-southeast-2
    }
  end

  # set this to reduce the regions you typically use
  attr_writer :regions


  # TODO change default region
  REGION_MAP = {
    nil              => 'us-west-2',
    "virginia"       => 'us-east-1',
    'syd'            => 'ap-southeast-2',
    'sydney'         => 'ap-southeast-2',
    'oregon'         => 'us-west-2',
    'us-east-1'      => 'us-east-1',
    'us-west-2'      => 'us-west-2',
    'ap-southeast-2' => 'ap-southeast-2',
  }


  DEFAULT_REGION = REGION_MAP[nil]


  def formal_region(region)
    REGION_MAP[region] || region
  end


  def region=(region)
    @region = formal_region(region)
    reset_services!
    @region
  end


  def region
    @region ||= 'us-east-1'
  end


  def in_region(region, &block)
    old_region = @region
    self.region = region
    yield
  ensure
    self.region = old_region
  end


  ## informal regions

  INFORMAL_REGIONS = {
    'us-east-1'          => "virginia",
    'ap-southeast-2'     => 'sydney',
    'us-west-2'          => 'oregon',
    'oregon'             => 'oregon',
    'sydney'             => 'sydney',
    'virginia'           => 'virginia',
  }
  def informal_region(region)
    INFORMAL_REGIONS[region.to_s]
  end

  def informal_regions
    regions.map {|r| informal_region(r)}
  end


  def is_ec2?
    @is_ec2 ||= has_ec2_mac? && can_metadata_connect?
  end


  def use_iam?
    @use_iam ||= begin
                   return false if ENV['FOG_RC']

                   case ENV["USE_IAM"]
                   when "no" # no forces off
                     false
                   when nil # not set - determine from env
                     is_ec2?
                   else # otherwise force true
                     true
                   end
                 end
  end


  def use_iam=(flag)
    @use_iam = flag
    reset_services!
    @use_iam
  end


  module Services
    # assumptions: use_iam? is defined

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
      @ec2 ||= ec2_for_region(region)
    end

    def ec2_for_region(region)
      Fog::Compute.new(provider: 'AWS', region: formal_region(region), use_iam_profile: use_iam?)
    end


    def elb
      @elb ||= elb_for_region(region)
    end

    def elb_for_region(region)
      Fog::AWS::ELB.new(region: formal_region(region), use_iam_profile: use_iam?)
    end


    def cache
      @cache ||= cache_for_region(region)
    end

    def cache_for_region(region)
      Fog::AWS::Elasticache.new(region: formal_region(region), use_iam_profile: use_iam?)
    end


    def cfn
      @cfn ||= cfn_for_region(region)
    end

    def cfn_for_region(region)
      Fog::AWS::CloudFormation.new(region: formal_region(region).tapp, use_iam_profile: use_iam?)
    end


    def s3
      @s3 ||= s3_for_region(region)
    end

    def s3_for_region(region)
      Fog::Storage.new(provider: 'AWS', region: formal_region(region), use_iam_profile: use_iam?)
    end


    def cw
      @cw ||= cloudwatch_for_region(region)
    end

    def cloudwatch_for_region(region)
      Fog::AWS::CloudWatch.new(region: formal_region(region), use_iam_profile: use_iam?)
    end


    def rds
      @rds ||= rds_for_region(region)
    end

    def rds_for_region(region)
      Fog::AWS::RDS.new(region: formal_region(region), use_iam_profile: use_iam?)
    end


    def auto_scaling
      @auto_scaling ||= auto_scaling_for_region(region)
    end

    def auto_scaling_for_region(region)
      Fog::AWS::AutoScaling.new(region: formal_region(region), use_iam_profile: use_iam?)
    end


    #################
    #  region free  #
    #################


    def r53
      @r53 ||= Fog::DNS.new(provider: 'AWS', use_iam_profile: use_iam?)
    end

    def iam
      @iam ||= Fog::AWS::IAM.new()
    end
  end


  module EC2
    # stolen from ohai.
    # XXX Seems to give false-positives.
    def can_metadata_connect?(addr="169.254.169.254", port=80, timeout=2)
      t = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
      saddr = Socket.pack_sockaddr_in(port, addr)
      connected = false

      begin
        t.connect_nonblock(saddr)
      rescue Errno::EINPROGRESS
        r,w,e = IO::select(nil,[t],nil,timeout)
        if !w.nil?
          connected = true
        else
          begin
            t.connect_nonblock(saddr)
          rescue Errno::EISCONN
            t.close
            connected = true
          rescue SystemCallError
          end
        end
      rescue SystemCallError
      end
      connected
    end


    def has_ec2_mac?
      arp = Pathanme("/proc/net/arp")
      arp.exist? && arp.read[/fe:ff:ff:ff:ff:ff.*eth0/]
    end
  end


  include Services
  include EC2
end
