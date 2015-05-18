class AutomationMessage < ActiveRecord::Base
  MESSAGE_TYPES = %w(error success failure info)
  WORKFLOW_TYPES = %w(administrative archive delivery patron production qa repository unknown)
  APPS = %w(tracksys)

  WORKFLOW_TYPES_HASH = {
    'CreateDlManifestProcessor' => 'administrative',
    'CreateStatsReportProcessor' => 'administrative',
    'SendUnitToArchiveProcessor' => 'archive',
    'StartManualUploadToArchiveMigrationProcessor' => 'archive',
    'StartManualUploadToArchiveBatchMigrationProcessor' => 'archive',
    'StartManualUploadToArchiveProcessor' => 'archive',
    'StartManualUploadToArchiveProductionProcessor' => 'archive',
    'UpdateOrderDateArchivingCompleteProcessor' => 'archive',
    'UpdateUnitArchiveIdProcessor' => 'archive',
    'UpdateUnitDateArchivedProcessor' => 'archive',
    'CreateDlDeliverablesProcessor' => 'repository',
    'CreateNewFedoraObjectsProcessor' => 'repository',
    'IngestDcMetadataProcessor' => 'repository',
    'IngestDescMetadataProcessor' => 'repository',
    'IngestJp2kProcessor' => 'repository',
    'IngestMarcProcessor' => 'repository',
    'IngestRelsExtProcessor' => 'repository',
    'IngestRelsIntProcessor' => 'repository',
    'IngestRightsMetadataProcessor' => 'repository',
    'IngestSolrDocProcessor' => 'repository',
    'IngestTechMetadataProcessor' => 'repository',
    'IngestTranscriptionProcessor' => 'repository',
    'PropogateAccessPoliciesProcessor' => 'repository',
    'PropogateDiscoverabilityProcessor' => 'repository',
    'PropogateIndexingScenariosProcessor' => 'repository',
    'QueueObjectsForFedoraProcessor' => 'repository',
    'SendCommitToSolrProcessor' => 'repository',
    'StartIngestFromArchiveProcessor' => 'repository',
    'UpdateFedoraDatastreamsProcessor' => 'repository',
    'UpdateUnitDateDlDeliverablesReadyProcessor' => 'repository',
    'UpdateUnitDateQueuedForIngestProcessor' => 'repository',
    'CheckUnitDeliveryModeProcessor' => 'qa',
    'CopyMetadataToMetadataDirectoryProcessor' => 'qa',
    'CopyUnitForDeliverableGenerationProcessor' => 'delivery',
    'ImportUnitIviewXMLProcessor' => 'qa',
    'QaFilesystemAndIviewXmlProcessor' => 'qa',
    'QaOrderDataProcessor' => 'qa',
    'QaUnitDataProcessor' => 'qa',
    'StartFinalizationMigrationProcessor' => 'qa',
    'StartFinalizationProcessor' => 'qa',
    'StartFinalizationProductionProcessor' => 'qa',
    'UpdateOrderDateFinalizationBegunProcessor' => 'qa',
    'CopyArchivedFilesToProductionProcessor' => 'patron',
    'CopyDirectoryFromArchiveProcessor' => 'patron',
    'SendFeeEstimateToCustomerProcessor' => 'patron',
    'UpdateOrderDateFeeEstimateSentToCustomerProcessor' => 'patron',
    'UpdateOrderStatusApprovedProcessor' => 'patron',
    'UpdateOrderStatusCanceledProcessor' => 'patron',
    'UpdateOrderStatusDeferredProcessor' => 'patron',
    'CheckOrderDateArchivingCompleteProcessor' => 'delivery',
    'CheckOrderDeliveryMethodProcessor' => 'delivery',
    'CheckOrderReadyForDeliveryProcessor' => 'delivery',
    'CheckOrderFeeProcessor' => 'delivery',
    'CreateInvoiceProcessor' => 'delivery',
    'CreatePatronDeliverablesProcessor' => 'delivery',
    'CreateOrderEmailProcessor' => 'delivery',
    'CreateOrderPdfProcessor' => 'delivery',
    'CreateOrderZipProcessor' => 'delivery',
    'CreateUnitDeliverablesProcessor' => 'delivery',
    'DeleteUnitCopyForDeliverableGenerationProcessor' => 'delivery',
    'MoveCompletedDirectoryToDeleteDirectoryProcessor' => 'delivery',
    'MoveDeliverablesToDeliveredOrdersDirectoryProcessor' => 'delivery',
    'QueueUnitDeliverablesProcessor' => 'delivery',
    'SendOrderEmailProcessor' => 'delivery',
    'UpdateOrderDateCustomerNotifiedProcessor' => 'delivery',
    'UpdateOrderDatePatronDeliverablesCompleteProcessor' => 'delivery',
    'UpdateOrderEmailDateProcessor' => 'delivery',
    'UpdateUnitDatePatronDeliverablesReadyProcessor' => 'delivery',
    'BurstPdfProcessor' => 'production',
    'CreateImageTechnicalMetadataAndThumbnailProcessor' => 'production',
    'CreateMasterFileRecordsFromTifAndTextProcessor' => 'production',
    'CreateTextFromPdfProcessor' => 'production',
    'CreateTifImagesFromPdfProcessor' => 'production',
    'SendPdfUnitToFinalizationDirProcessor' => 'production',
    'PurgeCacheProcessor' => 'administrative'
  }
  belongs_to :messagable, polymorphic: true, counter_cache: true

  validates :message, :app, :processor, :message_type, :workflow_type, presence: true
  validates :workflow_type, inclusion: { in: WORKFLOW_TYPES,
                                         message: 'must be one of these values: ' + WORKFLOW_TYPES.join(', ') }
  validates :message_type, inclusion: { in: MESSAGE_TYPES,
                                        message: 'must be one of these values: ' + MESSAGE_TYPES.join(', ') }
  validates :app, inclusion: { in: APPS,
                               message: 'must be one of these values: ' + APPS.join(', ') }
  validates :messagable, presence: true

  before_save do
    self.active_error = 0 if active_error.nil?
  end

  scope :has_active_error, where('active_error = 1')
  scope :has_inactive_error, where('active_error = 0')
  scope :archive_workflow, where("workflow_type = 'archive'")
  scope :qa_workflow, where("workflow_type = 'qa'")
  scope :patron_workflow, where("workflow_type = 'patron'")
  scope :repository_workflow, where("workflow_type = 'repository'")
  scope :delivery_workflow, where("workflow_type = 'delivery'")
  scope :administrative_workflow, where("workflow_type = 'administrative'")
  scope :production_workflow, where("workflow_type = 'production'")
  scope :errors, where("message_type = 'error'")
  scope :failures, where("message_type = 'failure'")
  scope :success, where("message_type = 'success'")

  # Returns a string containing a brief, general description of this
  # class/model.
  def self.class_description
    'Automation Message is a message sent during an automated process, saved to the database for later review by staff.'
  end

  #------------------------------------------------------------------
  # public instance methods
  #------------------------------------------------------------------

  # Formats +app+ value for display
  def app_display
    case app
    when 'deligen'
      'Deliverables Generator'
    else
      app.to_s
    end
  end

  # Formats +processor+ value for display
  def processor_display
    processor.to_s.humanize_camelcase.sub(/Dl /, 'DL ')
  end

  # # Choice of parent for an AutomationMessage object is variable.  Since an AutomationMessage object
  # # can be associated with a MasterFile, Unit, Order, Bibl or Component, we must impose a
  # # priority list in case an AutomationMessage object is associated with more than one.  The preference is:
  # #
  # # MasterFile
  # # Unit
  # # Order
  # # Bibl
  # # Component
  # def parent
  #   if self.master_file_id
  #     return MasterFile.find(master_file_id)
  #   elsif self.unit_id
  #     return Unit.find(unit_id)
  #   elsif self.order_id
  #     return Order.find(order_id)
  #   elsif self.bibl_id
  #     return Bibl.find(bibl_id)
  #   elsif self.component_id
  #     return Component.find(component_id)
  #   end
  # end

  # Formats +app+ and +processor+ values into a single user-friendly display
  # value indicating the sender of the message
  def sender
    out = app_display
    out += ', ' if app && processor
    out += processor_display
  end
end
