##
# This class allows an thumbnail preset to be created by chaining method calls until
# you have the configuration you want.
# You can then call to_h to make a hash to pass to a variant or preview.

# Examples:
#
#   ThumbnailPreset.default
#   ThumbnailPreset.default.scale_1080
#   ThumbnailPreset.default.scale_720
#   ThumbnailPreset.default.scale_360
#
class ThumbnailPreset
  def self.default
    new.scale_720
  end

  def initialize(overrides={})
    @presets = {}.merge(overrides)
  end

  def to_h
    @presets
  end

  def add!(new)
    @presets.merge!(new)
    self
  end

  def scale_1080
    add!(resize: "1080x720", gravity: "center", background: "black", extent: "1080x720")
  end

  def scale_720
    add!(resize: "720x560", gravity: "center", background: "black", extent: "720x560")
  end

  def scale_360
    add!(resize: "360x240", gravity: "center", background: "black", extent: "360x240")
  end
end
