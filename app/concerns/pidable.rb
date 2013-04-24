require "#{Hydraulics.concerns_dir}/pidable"

module Pidable

  # Override Hydraulics method so as to apply local PID namespaces
  def assign_pid
    self.pid = get_pid("#{FEDORA_NAMESPACE}") if self.pid.nil?
  end

  # Methods for ingest and Fedora management workflows
  def update_metadata(datastream)
    message = ActiveSupport::JSON.encode( { :object_class => self.class.to_s, :object_id => self.id, :datastream => datastream })
    publish :update_fedora_datastreams, message
  end
end
