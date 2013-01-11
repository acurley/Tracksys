class IngestSolrDocProcessor < ApplicationProcessor

  require 'fedora'
  require 'hydra'
  require 'nokogiri'

  subscribes_to :ingest_solr_doc, {:ack=>'client', 'activemq.prefetchSize' => 1}
  
  def on_message(message)  
    logger.debug "IngestSolrDocProcessor received: " + message
    
    # decode JSON message into Ruby hash
    hash = ActiveSupport::JSON.decode(message).symbolize_keys

    # Validate incoming message
    raise "Parameter 'type' is reqiured" if hash[:type].blank?
    raise "Parameter 'type' must equal either 'ingest' or 'update'" unless hash[:type].match('ingest') or hash[:type].match('update')
    raise "Parameter 'object_class' is required" if hash[:object_class].blank?
    raise "Parameter 'object_id' is required" if hash[:object_id].blank?

    @type = hash[:type]
    @object_class = hash[:object_class]
    @object_id = hash[:object_id]
    @object = @object_class.classify.constantize.find(@object_id)
    @messagable_id = hash[:object_id]
    @messagable_type = hash[:object_class]
    @workflow_type = AutomationMessage::WORKFLOW_TYPES_HASH.fetch(self.class.name.demodulize)
    @pid = @object.pid
    instance_variable_set("@#{@object.class.to_s.underscore}_id", @object_id)   

    # Open Solr Connection
    @solr_connection = Solr::Connection.new("#{::STAGING_SOLR_URL}", :autocommit => :off)

    # If an object already has a handcrafted desc_metadata value, this will be used to populate the descMetadata datastream.
    if @object.respond_to?(:solr) and @object.solr
      doc = Nokogiri::XML(@object.solr)
      nodes = doc.xpath("//field[@name='repository_address_display']")
      nodes[0].content = FEDORA_PROXY_URL
      @object.solr = doc.to_xml
      @object.save!
      xml = @object.solr
      @solr_connection.add(Hydra.read_solr_xml(xml))
      Fedora.add_or_update_datastream(xml, @pid, 'solrArchive', 'Index Data for Posting to Solr', :controlGroup => 'M')
    else
      xml = Hydra.solr(@object)
      if xml # Tei and Component objects return nil!
        @solr_connection.add(Hydra.read_solr_xml(xml))
        Fedora.add_or_update_datastream(xml, @pid, 'solrArchive', 'Index Data for Posting to Solr', :controlGroup => 'M')
      end
    end

    if @object.is_a?(Bibl)
      @object.teis.each do |tei|
        if tei.include_in_dl? && tei.date_dl_ingest.nil?
          tei.create_new_fedora_objects
          on_success "Tei document #{tei.id} pushed to repository #{FEDORA_PROXY_URL}"
        end
      end
    end
    
    on_success "The solrArchive datastream has been created for #{@pid} - #{@object_class} #{@object_id} and posted to #{::STAGING_SOLR_URL}."
  end
end
