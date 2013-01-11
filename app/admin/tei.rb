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
          if tei.bibls
            tei.bibls.each do |b|
              table do
                tr do
                  td do
                    "Bibl record:"
                  end
                  td do
                    link_to "#{b.title}", admin_bibl_path(b)
                  end
                end
              end
            end
          end
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
      div :class => 'workflow_button' do button_to "Put into Digital Library", create_new_fedora_objects_admin_tei_path(:datastream => 'all'), :method => :put end
    end
    if tei.valid?
      div :class => 'workflow_button' do button_to "Update All Datastreams", update_metadata_admin_tei_path(:datastream => 'all'), :method => :put end
      div :class => 'workflow_button' do button_to "Update All XML Datastreams", update_metadata_admin_tei_path(:datastream => 'allxml'), :method => :put end
      div :class => 'workflow_button' do button_to "Update Dublin Core", update_metadata_admin_tei_path(:datastream => 'dc_metadata'), :method => :put end
      div :class => 'workflow_button' do button_to "Update Descriptive Metadata", update_metadata_admin_tei_path(:datastream => 'desc_metadata'), :method => :put end
      div :class => 'workflow_button' do button_to "Update Relationships", update_metadata_admin_tei_path(:datastream => 'rels_ext'), :method => :put end
      div :class => 'workflow_button' do button_to "Update Index Records", update_metadata_admin_tei_path(:datastream => 'solr_doc'), :method => :put end
    end
  end

 # Member actions for workflow
  member_action :create_new_fedora_objects, :method => :put do
    tei=Tei.find(params[:id])
    notice=String.new
    # are all related Bibls in Repo?
    if tei.bibls.not_in_digital_library
      then
        notice="I will also have to add some Bibls to Fedora.\n"
        bibls=tei.bibls.not_in_digital_library
        bibls.each do |b|
          b.create_new_fedora_objects
          # each Bibl object's ingest_solr_document message will seek Tei and ingest as needed
        end
      else
        notice="I will do my best to foist this upon poor Fedora.\n"
        tei.create_new_fedora_objects
    end
    flash[:notice] = notice
    redirect_to :back  
  end

  member_action :update_metadata, :method => :put do
    flash[:notice] = "Updating #{params[:datastream]} now..."
    redirect_to :back
  end

end
