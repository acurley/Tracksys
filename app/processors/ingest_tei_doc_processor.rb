class IngestTeiDocProcessor < ApplicationProcessor
  require 'fedora'
  require 'hydra'

  subscribes_to :ingest_tei_doc, :ack => 'client', 'activemq.prefetchSize' => 1

  def on_message(message)
    logger.debug 'IngestTeiDocProcessor received: ' + message

    # decode JSON message into Ruby hash
    hash = ActiveSupport::JSON.decode(message).symbolize_keys

    # Validate incoming message
    fail "Parameter 'type' is reqiured" if hash[:type].blank?
    fail "Parameter 'type' must equal either 'ingest' or 'update'" unless hash[:type].match('ingest') || hash[:type].match('update')
    fail "Parameter 'object_class' is required" if hash[:object_class].blank?
    fail "Parameter 'object_id' is required" if hash[:object_id].blank?

    @type = hash[:type]
    @object_class = hash[:object_class]
    @object_id = hash[:object_id]
    @object = @object_class.classify.constantize.find(@object_id)
    @messagable_id = hash[:object_id]
    @messagable_type = hash[:object_class]
    @workflow_type = AutomationMessage::WORKFLOW_TYPES_HASH.fetch(self.class.name.demodulize)

    @pid = @object.pid
    instance_variable_set("@#{@object.class.to_s.underscore}_id", @object_id)

    unless @object.exists_in_repo?
      logger.error "ERROR: Object #{@pid} not found in #{FEDORA_REST_URL}"
      Fedora.create_or_update_object(@object, @object.title.to_s)
    end

    xml = File.read(File.join(TEI_ARCHIVE_DIR, "#{@object_id}.tei.xml"))
    Fedora.add_or_update_datastream(xml, @pid, 'TEI', 'TEI Transcription Document', contentType: 'text/xml', mimeType: 'text/xml', controlGroup: 'M')

    dsLocation = Hydra.tei(@object)
    Fedora.add_or_update_datastream(xml, @pid, 'XTF', 'XTF View of TEI Datastream Content', dsLocation: dsLocation, controlGroup: 'E')

    FileUtils.cp File.join(TEI_ARCHIVE_DIR, "#{@object_id}.tei.xml"), File.join(XTF_DELIVERY_DIR, "#{@object.content_model.name}/#{@object_id}.tei.xml")

    on_success "The TEI datastream has been created for #{@pid} - #{@object_class} #{@object_id}."
  end
end
