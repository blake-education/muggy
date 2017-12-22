require "muggy/version"
require 'pathname'


module Muggy

  autoload :Fog, "muggy/fog"
  autoload :Sdk, "muggy/sdk"
  autoload :EC2, "muggy/ec2"

  module Support
    autoload :Memoisation, "muggy/support/memoisation"
  end


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
    'beijing'        => 'cn-north-1',
    'cn-north-1'     => 'cn-north-1',
  }


  DEFAULT_REGION = REGION_MAP[nil]


  def formal_region(region=self.region)
    REGION_MAP[region] || region
  end


  def region=(region)
    @region = formal_region(region)
    fog.reset_services!
    sdk.reset_services!
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
    'beijing'            => 'beijing',
    'cn-north-1'         => 'beijing',
  }
  def informal_region(region=nil)
    region ||= self.region
    INFORMAL_REGIONS[region.to_s]
  end


  def informal_regions
    regions.map {|r| informal_region(r)}
  end


  # we could look these up, but they hardly ever change
  # so lets just put them here
  # TODO flesh out
  AVAILABILITY_ZONES = {
    'us-east-1' => ('a'..'e'),
    'us-west-2' => ('a'..'c'),
    'ap-southeast-2' => ('a'..'c'),
    'cn-north-1' => ('a'..'b'),
  }.inject({}) {|zones,(name,azs)|
    zones[name] = azs.map {|az| "#{name}#{az}"}
    zones
  }.freeze

  def availability_zones(region=self.formal_region)
    AVAILABILITY_ZONES[region]
  end


  def random_availability_zone(region=self.formal_region)
    availability_zones(region).sample
  end




  def is_ec2?
    # TODO threadsafe
    unless instance_variable_defined?(:@is_ec2)
      @is_ec2 = Muggy::EC2.can_metadata_connect?
    end

    @is_ec2
  end


  def use_iam?
    unless instance_variable_defined?(:@use_iam)
      @use_iam = begin
                   if ENV['FOG_RC']
                     false
                   else
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
    end

    @use_iam
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


  def fog_rc
    Pathname(ENV['FOG_RC'] || "~/.fog").expand_path
  end


  extend self
end
