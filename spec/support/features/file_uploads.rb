module FileUploads
  def drop_file(path = default_attachment_path, selector: ".file-upload")
    find(selector).drop(path)
  end

  def choose_file(path = default_attachment_path, selector: "Browse files", **opts)
    page.attach_file(selector, path, **opts)
  end

  def default_attachment_path
    Rails.root.join("spec/fixtures/dummy.mp4")
  end
end
