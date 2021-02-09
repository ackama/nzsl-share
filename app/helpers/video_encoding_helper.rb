module VideoEncodingHelper
  # CCSD-1720 since the key for the video depends not only on the video encoder
  # preset options but also THE ORDER they are declared, lets make it only defined in one place.

  PRESET_MAP = {
    "1080p" => VideoEncodingPreset.default.muted.scale_1080,
    "720p" => VideoEncodingPreset.default.muted.scale_720,
    "360p" => VideoEncodingPreset.default.muted.scale_360
  }.freeze
end
