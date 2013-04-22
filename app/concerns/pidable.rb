require "#{Hydraulics.concerns_dir}/pidable"

module Pidable

  # Override Hydraulics method so as to apply local PID namespaces
  def assign_pid
    self.pid = get_pid("#{FEDORA_NAMESPACE}") if self.pid.nil?
  end
end
