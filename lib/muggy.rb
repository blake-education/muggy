require "muggy/version"
require 'pathname'


module Muggy

  autoload :Fog, "muggy/fog"
  autoload :Sdk, "muggy/sdk"
  autoload :EC2, "muggy/ec2"


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
    fog.reset_services!
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
  def informal_region(region=nil)
    region ||= self.region
    INFORMAL_REGIONS[region.to_s]
  end


  def informal_regions
    regions.map {|r| informal_region(r)}
  end


  def is_ec2?
    unless instance_variable_defined?(:@is_ec2)
      @is_ec2 = !!%x{/bin/hostname -d}[/\.compute\.internal$/]
    end
    @is_ec2
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
    fog.reset_services!
    @use_iam
  end


  def fog
    Muggy::Fog
  end


  def sdk
    Muggy::Sdk
  end


  extend self
end
