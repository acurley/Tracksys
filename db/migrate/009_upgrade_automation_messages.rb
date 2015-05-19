 class UpgradeAutomationMessages < ActiveRecord::Migration
   def change
     change_table(:automation_messages, bulk: true) do |t|
       t.integer :messagable_id, null: false
       t.string :messagable_type, null: false, limit: 20
       t.index [:messagable_id, :messagable_type]

       t.string :workflow_type
       t.index :workflow_type
       t.change :active_error, :boolean, null: false, default: 0
       t.change :message, :string
       t.remove :ead_ref_id
     end

     # Transition all legacy *_id to messagable_id and messagable_type
     say 'Updating AutomationMessage - Bibl relationship'
     AutomationMessage.where('bibl_id is not null').update_all("messagable_type = 'Bibl', messagable_id = bibl_id")

     say 'Updating AutomationMessage - Order relationship'
     AutomationMessage.where('order_id is not null').update_all("messagable_type = 'Order', messagable_id = order_id")

     say 'Updating AutomationMessage - Component relationship'
     AutomationMessage.where('component_id is not null').update_all("messagable_type = 'Component', messagable_id = component_id")

     say 'Updating AutomationMessage - MasterFile relationship'
     # Have to use a different procedure because this query's resultset is larger than lock table can handle
     AutomationMessage.where('master_file_id is not null').find_in_batches(batch_size: 100_000) do |am|
       ids = am.map(&:id)
       AutomationMessage.update_all ["messagable_type = 'MasterFile', messagable_id = master_file_id"], "id IN (#{ids.join(', ')})"
     end

     say 'Updating AutomationMessage - Unit relationship'
     AutomationMessage.where('unit_id is not null').update_all("messagable_type = 'Unit', messagable_id = unit_id")

     AutomationMessage.where('bibl_id is not null').update_all(bibl_id: nil)
     AutomationMessage.where('order_id is not null').update_all(order_id: nil)
     AutomationMessage.where('component_id is not null').update_all(component_id: nil)
     AutomationMessage.where('unit_id is not null').update_all(unit_id: nil)
     AutomationMessage.where('master_file_id is not null').find_in_batches(batch_size: 100_000) do |am|
       ids = am.map(&:id)
       AutomationMessage.update_all(["master_file_id = ''"], "id IN (#{ids.join(', ')})")
     end

     change_table(:automation_messages, bulk: true) do |t|
       t.remove :bibl_id
       t.remove :unit_id
       t.remove :master_file_id
       t.remove :order_id
       t.remove :component_id
     end

     # Update all AutomationMessages so that each message has a workflow_type appropriate to its processor
     administrative = %w(CreateStatsReportProcessor)

     administrative.each do|processor|
       AutomationMessage.where(processor: processor).update_all workflow_type: 'administrative'
     end

     archive = %w(SendUnitToArchiveProcessor
                  StartManualUploadToArchiveMigrationProcessor
                  StartManualUploadToArchiveProcessor
                  StartManualUploadToArchiveProductionProcessor
                  UpdateOrderDateArchivingCompleteProcessor
                  UpdateUnitArchiveIdProcessor
                  UpdateUnitDateArchivedProcessor)

     archive.each do|processor|
       AutomationMessage.where(processor: processor).update_all workflow_type: 'archive'
     end

     repository = %w(CreateDlDeliverablesProcessor
                     CreateNewFedoraObjectsProcessor
                     IngestDcMetadataProcessor
                     IngestDescMetadataProcessor
                     IngestJp2kProcessor
                     IngestMarcProcessor
                     IngestRelsExtProcessor
                     IngestRelsIntProcessor
                     IngestRightsMetadataProcessor
                     IngestSolrDocProcessor
                     IngestTechMetadataProcessor
                     IngestTranscriptionProcessor
                     PropogateAccessPoliciesProcessor
                     PropogateDiscoverabilityProcessor
                     PropogateIndexingScenariosProcessor
                     QueueObjectsForFedoraProcessor
                     SendCommitToSolrProcessor
                     StartIngestFromArchiveProcessor
                     UpdateFedoraDatastreamsProcessor
                     UpdateUnitDateDlDeliverablesReadyProcessor
                     UpdateUnitDateQueuedForIngestProcessor)

     # Given that there are so many repository based messages, we are forced to break them down into
     # increments of 50,000.
     repository.each do|processor|
       AutomationMessage.where(processor: processor).find_in_batches(batch_size: 50_000) do |am|
         ids = am.map(&:id)
         AutomationMessage.update_all(["workflow_type = 'repository'"], "id IN (#{ids.join(', ')})")
       end
     end

     qa = %w(CheckUnitDeliveryModeProcessor
             CopyMetadataToMetadataDirectoryProcessor
             ImportUnitIviewXMLProcessor
             QaFilesystemAndIviewXmlProcessor
             QaOrderDataProcessor
             QaUnitDataProcessor
             StartFinalizationMigrationProcessor
             StartFinalizationProcessor
             StartFinalizationProductionProcessor
             UpdateOrderDateFinalizationBegunProcessor)

     qa.each do|processor|
       AutomationMessage.where(processor: processor).update_all workflow_type: 'qa'
     end

     patron = %w(CopyArchivedFilesToProductionProcessor
                 CopyDirectoryFromArchiveProcessor
                 SendFeeEstimateToCustomerProcessor
                 UpdateOrderDateFeeEstimateSentToCustomerProcessor
                 UpdateOrderStatusApprovedProcessor
                 UpdateOrderStatusCanceledProcessor
                 UpdateOrderStatusDeferredProcessor)

     patron.each do|processor|
       AutomationMessage.where(processor: processor).update_all workflow_type: 'patron'
     end

     delivery = %w(CheckOrderDateArchivingCompleteProcessor
                   CheckOrderDeliveryMethodProcessor
                   CheckOrderReadyForDeliveryProcessor
                   CheckOrderFeeProcessor
                   CreateInvoiceProcessor
                   CreatePatronDeliverablesProcessor
                   CreateOrderEmailProcessor
                   CreateOrderPdfProcessor
                   CreateOrderZipProcessor
                   CreateUnitDeliverablesProcessor
                   DeleteUnitCopyForDeliverableGenerationProcessor
                   MoveCompletedDirectoryToDeleteDirectoryProcessor
                   MoveDeliverablesToDeliveredOrdersDirectoryProcessor
                   QueueUnitDeliverablesProcessor
                   SendOrderEmailProcessor
                   UpdateOrderDateCustomerNotifiedProcessor
                   UpdateOrderDatePatronDeliverablesCompleteProcessor
                   UpdateOrderEmailDateProcessor
                   UpdateUnitDatePatronDeliverablesReadyProcessor)

     delivery.each do|processor|
       AutomationMessage.where(processor: processor).update_all workflow_type: 'delivery'
     end

     production = %w(BurstPdfProcessor
                     CreateImageTechnicalMetadataAndThumbnailProcessor
                     CreateMasterFileRecordsFromTifAndTextProcessor
                     CreateTextFromPdfProcessor
                     CreateTifImagesFromPdfProcessor
                     SendPdfUnitToFinalizationDirProcessor)

     production.each do|processor|
       AutomationMessage.where(processor: processor).update_all workflow_type: 'production'
     end
   end
end
