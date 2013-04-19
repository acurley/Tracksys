# This module provides methods for requesting PIDs (persistent identifiers)
# from the digital library object management system (namely Fedora) and saving
# them to the appropriate records in this Tracking System (namely Bibl,
# MasterFile, and Component records).

module AssignPids

  # Returns one PID
  def self.get_pid(pid_namespace = nil)
    return request_pids(1, pid_namespace).first
  end

  #-----------------------------------------------------------------------------

  # Requests PIDs from an external PID-generating server. Requests number of
  # PIDs passed. Returns array of string values.
  def self.request_pids(pid_count, pid_namespace = nil)
    return Array.new if pid_count.to_i == 0

    if pid_namespace.nil?
      if Rails.env == 'production'
        pid_namespace = 'uva-lib'
      else
        # If you set the namespace to empty string, the PID generator will use
        # its default namespace, but since that default is subject to change
        # it's probably better to specify an obviously temp/testing namespace
        pid_namespace = 'test'
      end
    end

    # Set up REST client
    @resource = RestClient::Resource.new FEDORA_REST_URL, :user => Fedora_username, :password => Fedora_password

    url = "/objects/nextPID?numPIDs=#{pid_count}&namespace=#{pid_namespace}&format=xml"
    xml = Nokogiri.XML(@resource[url].send :post, '', :content_type => 'text/xml')

    # Given that Fedora 3.6 returns an XML document with different namespacing than previous version of Fedora, we will need to test
    # for the presence of a namespace and act accordingly.
    if xml.namespaces["xmlns"]
      pids = xml.xpath('//xmlns:pid').map(&:content)
    else
      pids = xml.xpath('//pid').map(&:content)
    end

    return pids
  end

end
