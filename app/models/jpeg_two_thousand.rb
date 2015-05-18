class JpegTwoThousand < MasterFile
  def say_hello
    "Hi! I am a #{type}"
  end

  def mime_type
    'image/jp2'
  end
end
