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

end