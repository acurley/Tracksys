ActiveAdmin.register Tei do
  config.sort_order = 'title_asc'
  actions :all, :except => [:destroy]
  
  menu :parent => "Miscellaneous"  

  scope :all, :default => true

  show :title => proc { truncate(tei.title, :length => 75) } do
    div :class => 'three-column' do
      panel "Basic Information", :toggle => 'show' do
        attributes_table_for tei do
          row :title
        end
      end
    end

    div :class => 'three-column' do
      panel "Detailed Bibliographic Information", :toggle => 'show' do
        attributes_table_for tei do
          row :title
          if tei.in_catalog?
            div do
              link_to "VIRGO record #{tei.catalog_key}", tei.physical_virgo_url, :target => "_blank"
            end
          else
            div do
              row :catalog_key if tei.catalog_key?
            end
          end
        end
      end
    end

    div :class => 'columns-none' do
      panel "Digital Library Information", :toggle => 'hide' do
        attributes_table_for tei do
          row ("In Digital Library?") do |tei|
            format_boolean_as_yes_no(tei.in_dl?)
          end
          row :pid
          if tei.in_dl?
            div do
              link_to "VIRGO", tei.dl_virgo_url, :target => "_blank"
            end
            div do
              link_to "Fedora", tei.fedora_url, :target => "_blank"
            end
          end
        end
      end
    end

  end


  sidebar "Digital Library Workflow", :only => [:show] do 
    if tei.valid?
      div :class => 'workflow_button' do button_to "Put into Digital Library", start_ingest_from_archive_admin_unit_path(:datastream => 'all'), :method => :put end
    end
    if tei.in_dl?
      div :class => 'workflow_button' do button_to "Update All Datastreams", update_metadata_admin_unit_path(:datastream => 'all'), :method => :put end
      div :class => 'workflow_button' do button_to "Update All XML Datastreams", update_metadata_admin_unit_path(:datastream => 'allxml'), :method => :put end
      div :class => 'workflow_button' do button_to "Update Dublin Core", update_metadata_admin_unit_path(:datastream => 'dc_metadata'), :method => :put end
      div :class => 'workflow_button' do button_to "Update Descriptive Metadata", update_metadata_admin_unit_path(:datastream => 'desc_metadata'), :method => :put end
      div :class => 'workflow_button' do button_to "Update Relationships", update_metadata_admin_unit_path(:datastream => 'rels_ext'), :method => :put end
      div :class => 'workflow_button' do button_to "Update Index Records", update_metadata_admin_unit_path(:datastream => 'solr_doc'), :method => :put end
    end
  end

 # Member actions for workflow
  member_action :start_ingest_from_archive, :method => :put do
  end

  member_action :update_metadata, :method => :put do 
  end

end