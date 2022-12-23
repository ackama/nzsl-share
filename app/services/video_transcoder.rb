class VideoTranscoder
  class TranscodeError < StandardError; end
  attr_reader :blob

  def initialize(options, logger = Rails.logger)
    @options = options
    @logger = logger
  end

  def transcode(blob)
    download_blob_to_tempfile(blob) do |input|
      draw "ffmpeg", "-y", "-i", input.path, *@options do |output|
        result = {
          io: output,
          filename: filename(blob, output),
          content_type: content_type(output)
        }

        return result unless block_given?

        yield result
      end
    end
  end

  private

  def filename(blob, output)
    basename = blob.filename.base
    extension = content_type(output).split("/").last
    [basename, extension].join(".")
  end

  def content_type(io)
    Marcel::MimeType.for(io)
  end

  # Downloads the blob to a tempfile on disk. Yields the tempfile.
  def download_blob_to_tempfile(blob, &block)
    blob.open tmpdir: tempdir, &block
  end

  # Executes a system command, capturing its binary output in a tempfile. Yields the tempfile.
  #
  # Use this method to shell out to a system library (e.g. muPDF or FFmpeg) for preview image
  # generation. The resulting tempfile can be used as the +:io+ value in an attachable Hash:
  #
  #   def preview
  #     download_blob_to_tempfile do |input|
  #       draw "ffmpeg", input.path, "--format", "png", "-" do |output|
  #         yield io: output, filename: "#{blob.filename.base}.mp4", content_type: "video/mp4"
  #       end
  #     end
  #   end
  #
  # The output tempfile is opened in the directory returned by #tempdir.
  def draw(*argv)
    open_tempfile do |file|
      argv = Array(argv) << file.path.to_s
      exec(*argv)

      yield file
    end
  end

  def open_tempfile
    tempfile = Tempfile.open("NZSL-VideoEncode-", tempdir)
    yield tempfile
  ensure
    tempfile.close!
  end

  def exec(*argv)
    @logger.info "Executing #{argv.join(" ")}"
    output = IO.popen(argv, err: %i[child out], &:read)
    @logger.debug output
    fail TranscodeError, output unless $CHILD_STATUS.success?

    true
  end

  def tempdir
    Dir.tmpdir
  end

  def ffmpeg_path
    (defined?(ActiveStorage) && ActiveStorage.paths[:ffmpeg]) || "ffmpeg"
  end
end
