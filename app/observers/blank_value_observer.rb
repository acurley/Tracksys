# = BlankValueObserver
#
# Sets all blank values (i.e. "") to nil.  Data submitted through forms often passes blank params after submit
# which provides inconsistent data; some fields may be nil, other blank.  This observer, which monitors all classes
# in the application, provides consistency and prevents blank values.
class BlankValueObserver < ActiveRecord::Observer
  observe ActiveRecord::Base.send(:descendants)

  # Scan each incoming record for attributes == "", if any, set them to nil and update the record
  # with the nil values.  Ignore this behavior if the attribute is an id.
  #
  # Done before validation in order to ensure that nil is a valid value.
  def before_save(record)
    atts = record.attributes
    atts.keep_if { |_key, value| value == '' }
    atts.keep_if { |key, _value| key !~ /id/ }
    atts.each { |key, _value| atts[key] = nil }
    if record.logger
      record.logger.debug "BlankValueObserver: before_save will update #{record.class} #{record.id}'s attributes #{atts.inspect}"
    end
    record.update_attributes(atts) unless atts.empty?
  end
end
