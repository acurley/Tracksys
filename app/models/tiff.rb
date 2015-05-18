class Tiff < MasterFile
  def say_hello
    "Hi! I am a #{type}"
  end

  def mime_type
    'image/tiff'
  end
end
