require 'socket'


module Muggy
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
      arp = "/proc/net/arp"
      File.exist?(arp) && File.read(arp)[/fe:ff:ff:ff:ff:ff.*eth0/]
    end


    extend self
  end
end
