# ImageTechMeta represents image technical metadata. An ImageTechMeta record is
# an extension of a single MasterFile record and is applicable only for a
# MasterFile of type "image".
class ImageTechMeta < ActiveRecord::Base
  belongs_to :master_file
  

  validates :master_file_id, :presence => true
  validates :master_file_id, :uniqueness => true
  validates :resolution, :width, :height, :depth, :numericality => {:greater_than => 0, :allow_nil => true}
  validates :master_file, :presence => {
    :message => "association with this MasterFile is no longer valid because the MasterFile object no longer exists."
  }

   def mime_type
    if format.blank?
      return nil
    else
      # image formats
      if format.match(/^(gif|jpeg|tiff)$/i)
        return "image/#{format.downcase}"
      elsif format.match(/^mrsid$/i)
        return "image/x-mrsid"
      elsif format.match(/^jpeg ?2000$/i)
        return 'image/jp2'
      # text formats
      elsif format == 'TEI-XML'
        return 'text/xml'
      # audio formats
      elsif format == 'WAV'
        return 'audio/wav'
      # video formats
      elsif format == 'AVI'
        return 'video/avi'
      else
        return nil
      end
    end
  end

  def ImageTechMeta.width_description
    return 'Image width/height in pixels.'
  end

  def ImageTechMeta.depth_description
    return 'Color depth in bits. Normally 1 for bitonal, 8 for grayscale, 24 for color.'
  end

  def ImageTechMeta.compression_description
    return 'Name of compression scheme, or "Uncompressed" for no compression.'
  end


  #------------------------------------------------------------------
  # public instance methods
  #------------------------------------------------------------------
  # Returns this record's +image_format+ value.
  def format
    return image_format
  end
end
