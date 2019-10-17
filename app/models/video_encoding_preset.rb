##
# This class allows an encoding preset to be created by chaining method calls until
# you have the preset you want.
# You can then call to_s to make an arg string, or to_a to get an args array to pass to
# a shell using something like popen.
#
# A set is used because it does not allow duplicates. This means that we can ensure that we're
# not preparing confusing arguments for FFMpeg
#
# Examples:
#
#   VideoEncodingPreset.default.scale_1080.muted
#   VideoEncodingPreset.default.scale_720
#   VideoEncodingPreset.new(["-level", "4"]).scale_1080
#
class VideoEncodingPreset
  def self.default
    new.mp4
  end

  def initialize(overrides=[])
    # These base presets are from https://gist.github.com/Vestride/278e13915894821e1d6f#convert-to-mp4
    @presets = Set.new(["-profile:v", "baseline", "-level", "3"]).merge(overrides)
  end

  delegate :to_a, to: :@presets

  def to_s
    to_a.join(" ")
  end

  def add!(enum)
    @presets = @presets.merge(enum)
    self
  end

  def mp4
    add! ["-f", "mp4"]
  end

  def scale_1080
    add! ["-vf", "scale=1080:-2"]
  end

  def scale_720
    add! ["-vf", "scale=720:-2"]
  end

  def scale_360
    add! ["-vf", "scale=360:-2"]
  end

  def muted
    add! ["-an"]
  end
end
